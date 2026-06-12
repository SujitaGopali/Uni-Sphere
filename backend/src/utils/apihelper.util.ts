export class ApiResponseHelper {
  public static success(status: number, message: string, data?: any, meta?: any) {
    return {
      status,
      success: true,
      message,
      data,
      meta,
    };
  }

  public static error(status: number, message: string) {
    return {
      status,
      success: false,
      message,
    };
  }
}
