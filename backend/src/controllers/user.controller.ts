import { NextFunction, Request, Response } from "express";
import { UserService } from "../services/user.service";
import { ApiResponseHelper } from "../utils/apihelper.util";
import { CreateUserDTO, LoginUserDTO } from "../dtos/user.dto";

export class UserController {
  private userService = new UserService();

  public register = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const parsedBody = CreateUserDTO.safeParse(req.body);
      if (!parsedBody.success) {
        const errorMsg = parsedBody.error.errors.map(e => e.message).join(", ");
        res.status(400).json(ApiResponseHelper.error(400, errorMsg));
        return;
      }

      const newUser = await this.userService.register(parsedBody.data);
      const userResponse = newUser.toObject();
      delete (userResponse as any).password;

      res.status(201).json(ApiResponseHelper.success(201, "User registered successfully", { user: userResponse }));
    } catch (error) {
      next(error);
    }
  };

  public login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const parsedBody = LoginUserDTO.safeParse(req.body);
      if (!parsedBody.success) {
        const errorMsg = parsedBody.error.errors.map(e => e.message).join(", ");
        res.status(400).json(ApiResponseHelper.error(400, errorMsg));
        return;
      }

      const { user, token } = await this.userService.login(parsedBody.data);
      const userResponse = user.toObject();
      delete (userResponse as any).password;

      res.status(200).json(ApiResponseHelper.success(200, "Login successful", { user: userResponse, token }));
    } catch (error) {
      next(error);
    }
  };
}
