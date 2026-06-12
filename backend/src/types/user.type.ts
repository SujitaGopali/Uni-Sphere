import { z } from "zod";
export const UserSchema = z.object({
  name: z.string().min(1, "Name is required"),
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters"),
  phone: z.string().optional().default(""),
  address: z.string().optional().default(""),
  role: z.enum(["admin", "user"]).default("user"),
});
export type UserType = z.infer<typeof UserSchema>;
