import { Request, Response, NextFunction } from 'express';
import { BookModel, MemberModel, Book, Member } from '../models/library.model';

// Book Controllers
export const BookController = {
  getAllBooks: (_req: Request, res: Response, next: NextFunction): void => {
    try {
      const books = BookModel.getAll();
      res.json({
        success: true,
        data: books,
        count: books.length,
      });
    } catch (error) {
      next(error);
    }
  },

  getBookById: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid book ID',
        });
        return;
      }

      const book = BookModel.getById(id);
      if (!book) {
        res.status(404).json({
          success: false,
          message: 'Book not found',
        });
        return;
      }

      res.json({
        success: true,
        data: book,
      });
    } catch (error) {
      next(error);
    }
  },

  createBook: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const { title, author, isbn, category, published_year, available_copies, total_copies } = req.body;

      // Validation
      if (!title || !author) {
        res.status(400).json({
          success: false,
          message: 'Title and author are required',
        });
        return;
      }

      const bookData: Omit<Book, 'id' | 'created_at' | 'updated_at'> = {
        title,
        author,
        isbn,
        category,
        published_year,
        available_copies,
        total_copies,
      };

      const book = BookModel.create(bookData);
      res.status(201).json({
        success: true,
        message: 'Book created successfully',
        data: book,
      });
    } catch (error: any) {
      if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        res.status(409).json({
          success: false,
          message: 'Book with this ISBN already exists',
        });
        return;
      }
      next(error);
    }
  },

  updateBook: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid book ID',
        });
        return;
      }

      const book = BookModel.update(id, req.body);
      if (!book) {
        res.status(404).json({
          success: false,
          message: 'Book not found',
        });
        return;
      }

      res.json({
        success: true,
        message: 'Book updated successfully',
        data: book,
      });
    } catch (error: any) {
      if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        res.status(409).json({
          success: false,
          message: 'Book with this ISBN already exists',
        });
        return;
      }
      next(error);
    }
  },

  deleteBook: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid book ID',
        });
        return;
      }

      const deleted = BookModel.delete(id);
      if (!deleted) {
        res.status(404).json({
          success: false,
          message: 'Book not found',
        });
        return;
      }

      res.json({
        success: true,
        message: 'Book deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  },
};

// Member Controllers
export const MemberController = {
  getAllMembers: (_req: Request, res: Response, next: NextFunction): void => {
    try {
      const members = MemberModel.getAll();
      res.json({
        success: true,
        data: members,
        count: members.length,
      });
    } catch (error) {
      next(error);
    }
  },

  getMemberById: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid member ID',
        });
        return;
      }

      const member = MemberModel.getById(id);
      if (!member) {
        res.status(404).json({
          success: false,
          message: 'Member not found',
        });
        return;
      }

      res.json({
        success: true,
        data: member,
      });
    } catch (error) {
      next(error);
    }
  },

  createMember: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const { name, email, phone, address } = req.body;

      // Validation
      if (!name || !email) {
        res.status(400).json({
          success: false,
          message: 'Name and email are required',
        });
        return;
      }

      // Basic email validation
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        res.status(400).json({
          success: false,
          message: 'Invalid email format',
        });
        return;
      }

      const memberData: Omit<Member, 'id' | 'membership_date' | 'created_at' | 'updated_at'> = {
        name,
        email,
        phone,
        address,
      };

      const member = MemberModel.create(memberData);
      res.status(201).json({
        success: true,
        message: 'Member created successfully',
        data: member,
      });
    } catch (error: any) {
      if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        res.status(409).json({
          success: false,
          message: 'Member with this email already exists',
        });
        return;
      }
      next(error);
    }
  },

  updateMember: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid member ID',
        });
        return;
      }

      // Email validation if provided
      if (req.body.email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(req.body.email)) {
          res.status(400).json({
            success: false,
            message: 'Invalid email format',
          });
          return;
        }
      }

      const member = MemberModel.update(id, req.body);
      if (!member) {
        res.status(404).json({
          success: false,
          message: 'Member not found',
        });
        return;
      }

      res.json({
        success: true,
        message: 'Member updated successfully',
        data: member,
      });
    } catch (error: any) {
      if (error.code === 'SQLITE_CONSTRAINT_UNIQUE') {
        res.status(409).json({
          success: false,
          message: 'Member with this email already exists',
        });
        return;
      }
      next(error);
    }
  },

  deleteMember: (req: Request, res: Response, next: NextFunction): void => {
    try {
      const id = parseInt(req.params.id);
      if (isNaN(id)) {
        res.status(400).json({
          success: false,
          message: 'Invalid member ID',
        });
        return;
      }

      const deleted = MemberModel.delete(id);
      if (!deleted) {
        res.status(404).json({
          success: false,
          message: 'Member not found',
        });
        return;
      }

      res.json({
        success: true,
        message: 'Member deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  },
};
