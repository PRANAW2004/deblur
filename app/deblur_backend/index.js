import express from "express";
import cors from 'cors';
import {
  CognitoIdentityProviderClient,
  SignUpCommand,
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
  console.log(SignUp);
    res.send("Data received");
});

app.listen(port, () => {
    console.log("Server running on port 8000");
});