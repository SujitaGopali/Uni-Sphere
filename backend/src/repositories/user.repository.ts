import { UserModel, IUser } from "../models/user.model";
import { CreateUserDTOType } from "../dtos/user.dto";

export class UserMongoRepository {
  public async findById(id: string): Promise<IUser | null> {
    return UserModel.findById(id);
  }

  public async findByEmail(email: string): Promise<IUser | null> {
    return UserModel.findOne({ email });
  }

  public async create(userData: CreateUserDTOType): Promise<IUser> {
    return UserModel.create(userData);
  }
}
