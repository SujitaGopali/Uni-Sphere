import dotenv from "dotenv";
dotenv.config();

export const PORT = process.env.PORT || "8089";
export const MONGO_URI = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/unisphere";
export const SECRET_KEY = process.env.JWT_SECRET || "unisphere_default_secret_key_12345";
