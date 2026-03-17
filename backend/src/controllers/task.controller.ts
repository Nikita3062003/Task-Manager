import { Response, NextFunction } from 'express';
import prisma from '../lib/prisma';
import { AppError } from '../utils/AppError';
import {
  createTaskSchema,
  updateTaskSchema,
  taskQuerySchema,
} from '../validators/task.validator';
import { AuthRequest } from '../middleware/auth.middleware';

export const getTasks = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const query = taskQuerySchema.parse(req.query);
    const { page, limit, status, priority, search, sortBy, sortOrder } = query;
    const skip = (page - 1) * limit;

    const where: any = { userId: req.userId };

    if (status) {
      where.status = status;
    }

    if (priority) {
      where.priority = priority;
    }

    if (search) {
      where.title = {
        contains: search,
      };
    }

    const [tasks, total] = await Promise.all([
      prisma.task.findMany({
        where,
        skip,
        take: limit,
        orderBy: { [sortBy]: sortOrder },
      }),
      prisma.task.count({ where }),
    ]);

    res.json({
      success: true,
      data: {
        tasks,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
          hasMore: skip + tasks.length < total,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

export const getTask = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = req.params.id as string;

    const task = await prisma.task.findFirst({
      where: { id: String(id), userId: req.userId as string },
    });

    if (!task) {
      throw new AppError('Task not found', 404);
    }

    res.json({
      success: true,
      data: { task },
    });
  } catch (error) {
    next(error);
  }
};

export const createTask = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const data = createTaskSchema.parse(req.body);

    const task = await prisma.task.create({
      data: {
        ...data,
        dueDate: data.dueDate ? new Date(data.dueDate) : null,
        userId: req.userId!,
      },
    });

    res.status(201).json({
      success: true,
      message: 'Task created successfully',
      data: { task },
    });
  } catch (error) {
    next(error);
  }
};

export const updateTask = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = req.params.id as string;
    const data = updateTaskSchema.parse(req.body);

    const existingTask = await prisma.task.findFirst({
      where: { id: String(id), userId: req.userId as string },
    });

    if (!existingTask) {
      throw new AppError('Task not found', 404);
    }

    const task = await prisma.task.update({
      where: { id: String(id) },
      data: {
        ...data,
        dueDate: data.dueDate !== undefined
          ? (data.dueDate ? new Date(data.dueDate) : null)
          : undefined,
      },
    });

    res.json({
      success: true,
      message: 'Task updated successfully',
      data: { task },
    });
  } catch (error) {
    next(error);
  }
};

export const deleteTask = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = req.params.id as string;

    const existingTask = await prisma.task.findFirst({
      where: { id: String(id), userId: req.userId as string },
    });

    if (!existingTask) {
      throw new AppError('Task not found', 404);
    }

    await prisma.task.delete({ where: { id: String(id) } });

    res.json({
      success: true,
      message: 'Task deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

export const toggleTask = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = req.params.id as string;

    const existingTask = await prisma.task.findFirst({
      where: { id: String(id), userId: req.userId as string },
    });

    if (!existingTask) {
      throw new AppError('Task not found', 404);
    }

    const newStatus = existingTask.status === 'DONE' ? 'TODO' : 'DONE';

    const task = await prisma.task.update({
      where: { id: String(id) },
      data: { status: newStatus },
    });

    res.json({
      success: true,
      message: `Task marked as ${newStatus}`,
      data: { task },
    });
  } catch (error) {
    next(error);
  }
};
