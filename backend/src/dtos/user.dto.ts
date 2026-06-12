import { z } from "zod";
import { UserSchema } from "../types/user.type";
export const CreateUserDTO = UserSchema.pick({
  name: true,
  email: true,
  password: true,
  phone: true,
  address: true,
});
export const LoginUserDTO = UserSchema.pick({
  email: true,
  password: true,
});
export type CreateUserDTOType = z.infer<typeof CreateUserDTO>;
export type LoginUserDTOType = z.infer<typeof LoginUserDTO>;
