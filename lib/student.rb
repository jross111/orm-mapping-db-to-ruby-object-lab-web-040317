require 'pry'

class Student
  attr_accessor :id, :name, :grade

  # def initialize(id: , name:, grade:)
  #   @id = :id
  #   @name = :name
  #   @grade = :grade
  # end

  def self.new_from_db(row)
    new_student = self.new
    new_student.id = row[0]
    new_student.name = row[1]
    new_student.grade = row[2]
    new_student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = <<-SQL
    SELECT *
    FROM students
    SQL
    all_students = DB[:conn].execute(sql)
    all_students.collect do |student|
      self.new_from_db(student)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
    SQL

    student_array = DB[:conn].execute(sql, name).flatten
    x = self.new_from_db(student_array)
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end


  def self.all_students_in_grade_x(grade)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = ?
      SQL
    DB[:conn].execute(sql, grade)
  end

  def self.count_all_students_in_grade_9
    self.all_students_in_grade_x(9)
  end

  def self.students_below_12th_grade
    grades_array = []
    for grade in 9...12
      grades_array << self.all_students_in_grade_x(grade)
    end
    grades_array.select do |grade_array|
      !!grade_array[0]
    end[0]
  end

  def self.first_x_students_in_grade_10(x)
    self.all_students_in_grade_x(10)[0...x]

  end

  def self.first_student_in_grade_10
   self.new_from_db(self.all_students_in_grade_x(10).first)
  end
end
