import mongoose from "mongoose";
import { MONGO_URI } from "../configs/constant";

export const connectDatabase = async (): Promise<void> => {
  try {
    console.log(`Connecting to MongoDB at ${MONGO_URI}...`);
    await mongoose.connect(MONGO_URI);
    console.log("Connected to MongoDB successfully");
  } catch (error) {
    console.error("MongoDB connection error:", error);
    process.exit(1);
  }
};
