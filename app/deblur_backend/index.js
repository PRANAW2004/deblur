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

dotenv.config();

console.log("Client ID:", process.env.COGNITO_CLIENT_ID);

const app = express();
app.use(cors());
app.use(express.json());

const client = new CognitoIdentityProviderClient({
  region: process.env.AWS_REGION,
});

const port = process.env.PORT || 8000;

app.get("/", (req,res) => {
    res.send("The server is up and running");
})

app.post("/signup", async (req,res) => {
  try{
      const {email, password} = req.body;
    console.log(email,password);
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
  }catch(err){
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
    console.log(email,password);

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


app.listen(port, () => {
    console.log("Server running on port 8000");
});