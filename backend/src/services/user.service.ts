import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { UserMongoRepository } from "../repositories/user.repository";
import { CreateUserDTOType, LoginUserDTOType } from "../dtos/user.dto";
import { HttpException } from "../exceptions/http-exception";
import { SECRET_KEY } from "../configs/constant";
import { IUser } from "../models/user.model";

export class UserService {
  private userRepository = new UserMongoRepository();

  public async register(userData: CreateUserDTOType): Promise<IUser> {
    const existingEmail = await this.userRepository.findByEmail(userData.email);
    if (existingEmail) {
      throw new HttpException(400, "Email is already registered");
    }

    const hashedPassword = await bcrypt.hash(userData.password, 10);
    const newUser = await this.userRepository.create({
      ...userData,
      password: hashedPassword,
    });

    return newUser;
  }

  public async login(loginData: LoginUserDTOType): Promise<{ user: IUser; token: string }> {
    const user = await this.userRepository.findByEmail(loginData.email);
    if (!user) {
      throw new HttpException(401, "Invalid email or password");
    }

    const isPasswordMatching = await bcrypt.compare(loginData.password, user.password);
    if (!isPasswordMatching) {
      throw new HttpException(401, "Invalid email or password");
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: user.role },
      SECRET_KEY,
      { expiresIn: "24h" }
    );

    return { user, token };
  }
}
