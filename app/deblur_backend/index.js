import express from "express";
import cors from 'cors';
import {
  CognitoIdentityProviderClient,
  SignUpCommand,
  ConfirmSignUpCommand,
  InitiateAuthCommand,
  ForgotPasswordCommand,
  ConfirmForgotPasswordCommand
} from "@aws-sdk/client-cognito-identity-provider";
import dotenv from "dotenv";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { v4 as uuidv4 } from "uuid";
import { SageMakerRuntimeClient, InvokeEndpointAsyncCommand } from "@aws-sdk/client-sagemaker-runtime";
import multer from "multer";
import { GetObjectCommand, HeadObjectCommand } from "@aws-sdk/client-s3";


dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const upload = multer({ storage: multer.memoryStorage() });

const s3 = new S3Client({ region: "us-east-1" });
const sm = new SageMakerRuntimeClient({ region: "us-east-1" });

const INPUT_BUCKET = "deblur-input-bucket";
const OUTPUT_BUCKET = "deblur-output-bucket";
const ENDPOINT_NAME = "deblur-async-endpoint";

const client = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const port = process.env.PORT || 8000;

app.get("/", (req, res) => {
  res.send("The server is up and running");
})

app.post("/signup", async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(email, password);
    const command = new SignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      Password: password,
      UserAttributes: [
        {
          Name: "email",
          Value: email,
        },
      ],
    });
    const SignUp = await client.send(command);
    res.send("success");
  } catch (err) {
    let message = "Something went wrong";
    console.log(err.name);
    switch (err.name) {
      case "UsernameExistsException":
        message = "User already exists";
        break;

      case "InvalidPasswordException":
        message =
          "Password must contain uppercase, lowercase, number, and special character";
        break;

      case "InvalidParameterException":
        message = "Invalid signup details";
        break;

      case "TooManyRequestsException":
        message = "Too many requests. Please try again later";
        break;
    }
    console.log(message);
    res.json({ error: message });
  }

});

app.post("/otpverify", async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        error: "Email and OTP are required",
      });
    }

    const command = new ConfirmSignUpCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      ConfirmationCode: otp,
    });

    await client.send(command);

    res.send("success");

  } catch (err) {
    console.log(err.name);

    let message = "OTP verification failed";

    switch (err.name) {
      case "CodeMismatchException":
        message = "Invalid OTP";
        break;

      case "ExpiredCodeException":
        message = "OTP has expired";
        break;

      case "UserNotFoundException":
        message = "User not found";
        break;

      case "NotAuthorizedException":
        message = "User already verified";
        break;
    }

    res.json({ error: message });
  }
});

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    console.log(email, password);

    if (!email || !password) {
      return res.status(400).json({
        error: "Email and password are required",
      });
    }

    const command = new InitiateAuthCommand({
      AuthFlow: "USER_PASSWORD_AUTH",
      ClientId: process.env.COGNITO_CLIENT_ID,
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    });

    const response = await client.send(command);

    const { AccessToken, IdToken, RefreshToken, ExpiresIn } =
      response.AuthenticationResult;

    res.status(200).json({
      message: "success",
      accessToken: AccessToken,
      idToken: IdToken,
      refreshToken: RefreshToken,
      expiresIn: ExpiresIn,
    });

  } catch (err) {
    console.log(err.name);

    let message = "Login failed";

    switch (err.name) {
      case "NotAuthorizedException":
        message = "Invalid email or password";
        break;

      case "UserNotConfirmedException":
        message = "Please verify your email first";
        break;

      case "UserNotFoundException":
        message = "User does not exist";
        break;
    }

    res.json({ error: message });
  }
});

app.post("/forgot-password", async (req, res) => {
  try {
    const { email } = req.body;

    const command = new ForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
    });

    await client.send(command);

    res.send("success");

  } catch (err) {
    console.log(err.name);

    let message = "Failed to send OTP";

    switch (err.name) {
      case "UserNotFoundException":
        message = "User does not exist";
        break;

      case "LimitExceededException":
        message = "Too many attempts, try later";
        break;
    }

    res.json({ error: message });
  }
});

app.post("/confirm-forgot-password", async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;

    const command = new ConfirmForgotPasswordCommand({
      ClientId: process.env.COGNITO_CLIENT_ID,
      Username: email,
      ConfirmationCode: otp,
      Password: newPassword,
    });

    await client.send(command);

    res.send("success");

  } catch (err) {
    console.log(err.name);

    let message = "Password reset failed";

    switch (err.name) {
      case "CodeMismatchException":
        message = "Invalid OTP";
        break;

      case "ExpiredCodeException":
        message = "OTP expired";
        break;

      case "InvalidPasswordException":
        message =
          "Password must contain uppercase, lowercase, number, and special character";
        break;
    }

    res.json({ error: message });
  }
});

const waitForS3Object = async (bucket, key, timeoutMs = 60000) => {
  const start = Date.now();

  while (Date.now() - start < timeoutMs) {
    try {
      const obj = await s3.send(
        new GetObjectCommand({ Bucket: bucket, Key: key })
      );
      return obj; // SUCCESS
    } catch (err) {
      if (err.name !== "NoSuchKey") {
        console.error("S3 error:", err.name);
      }
      await new Promise(r => setTimeout(r, 2000));
    }
  }

  throw new Error("Timed out waiting for SageMaker async output");
};


const parseS3Uri = (uri) => {
  const [, , bucket, ...keyParts] = uri.split("/");
  return {
    bucket,
    key: keyParts.join("/"),
  };
};


app.post("/deblur", upload.single("image"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "Image is required" });
    }

    const imageId = uuidv4();
    const inputKey = `inputs/${imageId}.jpg`;
    const outputKey = `async-results/${imageId}.out`;

    // Upload input image
    await s3.send(
      new PutObjectCommand({
        Bucket: INPUT_BUCKET,
        Key: inputKey,
        Body: req.file.buffer,
        ContentType: "image/jpeg",
      })
    );

    // Invoke async endpoint
    const response = await sm.send(
      new InvokeEndpointAsyncCommand({
        EndpointName: "deblur-async-endpoint-main-v1v2",
        InputLocation: `s3://${INPUT_BUCKET}/${inputKey}`,
        ContentType: "image/jpeg",
      })
    );
    

    const outputS3Uri = response.OutputLocation;

    const { bucket, key } = parseS3Uri(outputS3Uri);

    // Wait for EXACT file SageMaker creates
    const result = await waitForS3Object(bucket, key);

    const chunks = [];
    for await (const chunk of result.Body) {
      chunks.push(chunk);
    }

    const imageBuffer = Buffer.concat(chunks);


    // Send image
    res.setHeader("Content-Type", "image/jpeg");
    res.send(imageBuffer);

  } catch (err) {
    console.error("Async deblur error:", err);
    res.status(500).json({ error: "Async deblur failed" });
  }
});



app.listen(port, () => {
  console.log("Server running on port 8000");
});