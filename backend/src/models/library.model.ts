import db from '../config/database';

export interface Book {
  id?: number;
  title: string;
  author: string;
  isbn?: string;
  category?: string;
  published_year?: number;
  available_copies?: number;
  total_copies?: number;
  created_at?: string;
  updated_at?: string;
}

export interface Member {
  id?: number;
  name: string;
  email: string;
  phone?: string;
  address?: string;
  membership_date?: string;
  created_at?: string;
  updated_at?: string;
}

export interface Transaction {
  id?: number;
  book_id: number;
  member_id: number;
  transaction_type: 'borrow' | 'return';
  transaction_date?: string;
  due_date?: string;
  return_date?: string;
  fine_amount?: number;
  status?: 'active' | 'completed' | 'overdue';
  created_at?: string;
}

// Book Model Methods
export const BookModel = {
  getAll: (): Book[] => {
    const stmt = db.prepare('SELECT * FROM books ORDER BY created_at DESC');
    return stmt.all() as Book[];
  },

  getById: (id: number): Book | undefined => {
    const stmt = db.prepare('SELECT * FROM books WHERE id = ?');
    return stmt.get(id) as Book | undefined;
  },

  create: (book: Omit<Book, 'id' | 'created_at' | 'updated_at'>): Book => {
    const stmt = db.prepare(`
      INSERT INTO books (title, author, isbn, category, published_year, available_copies, total_copies)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);
    const result = stmt.run(
      book.title,
      book.author,
      book.isbn || null,
      book.category || null,
      book.published_year || null,
      book.available_copies || 1,
      book.total_copies || 1
    );
    return BookModel.getById(result.lastInsertRowid as number) as Book;
  },

  update: (id: number, book: Partial<Book>): Book | undefined => {
    const updates: string[] = [];
    const values: any[] = [];

    if (book.title !== undefined) {
      updates.push('title = ?');
      values.push(book.title);
    }
    if (book.author !== undefined) {
      updates.push('author = ?');
      values.push(book.author);
    }
    if (book.isbn !== undefined) {
      updates.push('isbn = ?');
      values.push(book.isbn);
    }
    if (book.category !== undefined) {
      updates.push('category = ?');
      values.push(book.category);
    }
    if (book.published_year !== undefined) {
      updates.push('published_year = ?');
      values.push(book.published_year);
    }
    if (book.available_copies !== undefined) {
      updates.push('available_copies = ?');
      values.push(book.available_copies);
    }
    if (book.total_copies !== undefined) {
      updates.push('total_copies = ?');
      values.push(book.total_copies);
    }

    if (updates.length === 0) {
      return BookModel.getById(id);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const stmt = db.prepare(`UPDATE books SET ${updates.join(', ')} WHERE id = ?`);
    stmt.run(...values);
    return BookModel.getById(id);
  },

  delete: (id: number): boolean => {
    const stmt = db.prepare('DELETE FROM books WHERE id = ?');
    const result = stmt.run(id);
    return result.changes > 0;
  },
};

// Member Model Methods
export const MemberModel = {
  getAll: (): Member[] => {
    const stmt = db.prepare('SELECT * FROM members ORDER BY created_at DESC');
    return stmt.all() as Member[];
  },

  getById: (id: number): Member | undefined => {
    const stmt = db.prepare('SELECT * FROM members WHERE id = ?');
    return stmt.get(id) as Member | undefined;
  },

  create: (member: Omit<Member, 'id' | 'membership_date' | 'created_at' | 'updated_at'>): Member => {
    const stmt = db.prepare(`
      INSERT INTO members (name, email, phone, address)
      VALUES (?, ?, ?, ?)
    `);
    const result = stmt.run(
      member.name,
      member.email,
      member.phone || null,
      member.address || null
    );
    return MemberModel.getById(result.lastInsertRowid as number) as Member;
  },

  update: (id: number, member: Partial<Member>): Member | undefined => {
    const updates: string[] = [];
    const values: any[] = [];

    if (member.name !== undefined) {
      updates.push('name = ?');
      values.push(member.name);
    }
    if (member.email !== undefined) {
      updates.push('email = ?');
      values.push(member.email);
    }
    if (member.phone !== undefined) {
      updates.push('phone = ?');
      values.push(member.phone);
    }
    if (member.address !== undefined) {
      updates.push('address = ?');
      values.push(member.address);
    }

    if (updates.length === 0) {
      return MemberModel.getById(id);
    }

    updates.push('updated_at = CURRENT_TIMESTAMP');
    values.push(id);

    const stmt = db.prepare(`UPDATE members SET ${updates.join(', ')} WHERE id = ?`);
    stmt.run(...values);
    return MemberModel.getById(id);
  },

  delete: (id: number): boolean => {
    const stmt = db.prepare('DELETE FROM members WHERE id = ?');
    const result = stmt.run(id);
    return result.changes > 0;
  },
};
