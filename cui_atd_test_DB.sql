-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 13, 2025 at 01:45 PM
-- Server version: 8.0.41-0ubuntu0.24.04.1
-- PHP Version: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cui_atd`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_login`
--

CREATE TABLE `admin_login` (
  `id` int NOT NULL,
  `username` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('registrar','department','faculty') NOT NULL,
  `department_id` int DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin_login`
--

INSERT INTO `admin_login` (`id`, `username`, `password`, `role`, `department_id`, `status`) VALUES
(1, 'csadmin@cuiatd.com', '$2y$10$GWGGD9zDp6d0b1WN1B6OM.MO5Qqk4tpXx2BzTMWqgXVurYI0jQKXa', 'department', 9, 'active'),
(2, 'admin@cuiatd.com', '$2y$10$pOYD/.CvHItQDtzb6T2tXOtXgNh0VkaALA4yEJHn4r6PlbVLFAiii', 'department', 9, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `target` enum('all','program','batch','section') NOT NULL,
  `target_id` int DEFAULT NULL COMMENT 'ID of program/batch/section',
  `posted_by` int NOT NULL,
  `post_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `content`, `target`, `target_id`, `posted_by`, `post_date`, `expiry_date`) VALUES
(1, 'University Closed on Eid Holidays', 'The university will remain closed from June 16 to June 20 for Eid-ul-Fitr celebrations. Classes will resume on June 21.', 'all', NULL, 1, '2025-04-13 11:45:56', '2025-06-21'),
(2, 'BCS Final Year Project Submission Deadline', 'Attention all BCS final year students: Project reports must be submitted by July 15, 2025. Late submissions will not be accepted.', 'program', 8, 1, '2025-04-13 11:45:56', '2025-07-16'),
(3, 'FA21 Convocation Registration', 'FA21 batch students: Convocation registration begins on August 1st. Please check your emails for details.', 'batch', 1, 1, '2025-04-13 11:45:56', '2025-08-15'),
(4, 'Semester 8 Time Table Update', 'Section A students: There has been a room change for CSC498 lab sessions. New location: Lab 3, CS Block.', 'section', 1, 1, '2025-04-13 11:45:56', '2025-04-30'),
(5, 'Midterm Examination Schedule', 'Midterm examinations will be held from May 5 to May 12. Check the examination portal for your schedule.', 'all', NULL, 2, '2025-04-13 11:45:56', '2025-05-13');

-- --------------------------------------------------------

--
-- Table structure for table `assessments`
--

CREATE TABLE `assessments` (
  `id` int NOT NULL,
  `course_offering_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('assignment','quiz','midterm','final','project') NOT NULL,
  `total_marks` decimal(5,2) NOT NULL,
  `weightage` decimal(5,2) NOT NULL,
  `due_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `batches`
--

CREATE TABLE `batches` (
  `id` int NOT NULL,
  `session` varchar(10) NOT NULL COMMENT 'Format: FA21 for Fall 2021',
  `program_id` int NOT NULL,
  `status` enum('active','graduated','discontinued') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `batches`
--

INSERT INTO `batches` (`id`, `session`, `program_id`, `status`) VALUES
(1, 'FA21', 8, 'active'),
(2, 'SP22', 9, 'active'),
(3, 'FA22', 9, 'active'),
(4, 'SP23', 9, 'active'),
(5, 'FA23', 9, 'active'),
(6, 'SP24', 9, 'active'),
(7, 'FA24', 9, 'active'),
(8, 'SP25', 9, 'active'),
(9, 'FA25', 9, 'active'),
(10, 'SP22', 8, 'active'),
(11, 'FA22', 8, 'active'),
(12, 'SP23', 8, 'active'),
(13, 'FA23', 8, 'active'),
(14, 'SP24', 8, 'active'),
(15, 'FA24', 8, 'active'),
(16, 'SP25', 8, 'active'),
(17, 'FA25', 8, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `conflict_requests`
--

CREATE TABLE `conflict_requests` (
  `id` int NOT NULL,
  `student_id` int NOT NULL,
  `course_offering_id` int NOT NULL,
  `conflict_with` int NOT NULL COMMENT 'course_offering_id',
  `request_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `resolved_by` int DEFAULT NULL,
  `resolution_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` int NOT NULL,
  `code` varchar(20) NOT NULL,
  `title` varchar(100) NOT NULL,
  `credit_hours` int NOT NULL,
  `theory_hours` int DEFAULT NULL,
  `lab_hours` int DEFAULT NULL,
  `department_id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `description` text,
  `status` enum('active','inactive') DEFAULT 'active',
  `prerequisites` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `code`, `title`, `credit_hours`, `theory_hours`, `lab_hours`, `department_id`, `category_id`, `description`, `status`, `prerequisites`) VALUES
(1, 'CSC102', 'Discrete Structures', 3, NULL, NULL, 9, 76, 'Fundamentals of discrete mathematics for computer science', 'active', NULL),
(2, 'CSC103', 'Programming Fundamentals', 4, NULL, NULL, 9, 76, 'Introduction to programming concepts', 'active', NULL),
(3, 'CSC211', 'Data Structures and Algorithms', 4, NULL, NULL, 9, 76, 'Fundamental data structures and algorithms', 'active', '[\"CSC103\"]'),
(4, 'CSC241', 'Object Oriented Programming', 4, NULL, NULL, 9, 76, 'Object-oriented programming concepts', 'active', '[\"CSC103\"]'),
(5, 'CSC270', 'Database Systems', 4, NULL, NULL, 9, 76, 'Database design and implementation', 'active', '[\"CSC211\"]'),
(6, 'CSC291', 'Software Engineering Concepts', 3, NULL, NULL, 9, 76, 'Software development methodologies', 'active', NULL),
(7, 'CSC323', 'Principles of Operating Systems', 4, NULL, NULL, 9, 76, 'Operating system concepts', 'active', '[\"CSC211\"]'),
(8, 'CSC340', 'Computer Networks', 4, NULL, NULL, 9, 76, 'Computer networking fundamentals', 'active', NULL),
(9, 'CSC432', 'Information Security', 3, NULL, NULL, 9, 76, 'Information security principles', 'active', NULL),
(10, 'CSC498', 'Senior Design Project I', 2, NULL, NULL, 9, 76, 'First part of capstone project', 'active', '[\"CSC241\",\"CSC270\",\"CSC291\",\"HUM102\"]'),
(11, 'CSC499', 'Senior Design Project II', 4, NULL, NULL, 9, 76, 'Second part of capstone project', 'active', '[\"CSC498\"]'),
(12, 'MTH104', 'Calculus and Analytic Geometry', 3, NULL, NULL, 9, 77, 'Calculus and analytic geometry', 'active', NULL),
(13, 'MTH231', 'Linear Algebra', 3, NULL, NULL, 9, 77, 'Linear algebra concepts', 'active', '[\"MTH104\"]'),
(14, 'MTH262', 'Statistics and Probability Theory', 3, NULL, NULL, 9, 77, 'Probability and statistics', 'active', NULL),
(15, 'PHY121', 'Applied Physics for Engineers', 4, NULL, NULL, 9, 77, 'Physics for engineering applications', 'active', NULL),
(16, 'CSC101', 'Introduction to ICT', 3, NULL, NULL, 9, 78, 'Introduction to information technology', 'active', NULL),
(17, 'CSC410', 'Professional Practices', 3, NULL, NULL, 9, 78, 'Professional ethics and practices', 'active', NULL),
(18, 'HUM100', 'English Comprehension and Composition', 3, NULL, NULL, 9, 78, 'English language skills', 'active', NULL),
(19, 'HUM102', 'Report Writing Skills', 3, NULL, NULL, 9, 78, 'Technical writing skills', 'active', '[\"HUM100\"]'),
(20, 'HUM103', 'Communication Skills', 3, NULL, NULL, 9, 78, 'Communication techniques', 'active', '[\"HUM100\"]'),
(21, 'HUM110', 'Islamic Studies', 3, NULL, NULL, 9, 78, 'Islamic teachings and principles', 'active', NULL),
(22, 'HUM111', 'Pakistan Studies', 3, NULL, NULL, 9, 78, 'History and culture of Pakistan', 'active', NULL),
(23, 'HUM114', 'Ethics', 3, NULL, NULL, 9, 78, 'Ethical principles and reasoning', 'active', NULL),
(24, 'CSC301', 'Design and Analysis of Algorithms', 3, NULL, NULL, 9, 80, 'Algorithm design and analysis', 'active', '[\"CSC211\"]'),
(25, 'CSC312', 'Theory of Automata', 3, NULL, NULL, 9, 80, 'Automata theory and formal languages', 'active', '[\"CSC102\"]'),
(26, 'CSC325', 'Computer Organization & Assembly Language', 4, NULL, NULL, 9, 80, 'Computer architecture and assembly', 'active', NULL),
(27, 'CSC334', 'Parallel and Distributed Computing', 3, NULL, NULL, 9, 80, 'Parallel computing concepts', 'active', '[\"CSC323\"]'),
(28, 'CSC441', 'Compiler Construction', 3, NULL, NULL, 9, 80, 'Compiler design principles', 'active', '[\"CSC312\"]'),
(29, 'CSC462', 'Artificial Intelligence', 4, NULL, NULL, 9, 80, 'AI fundamentals', 'active', '[\"CSC102\"]'),
(30, 'EEE241', 'Digital Logic Design', 4, NULL, NULL, 9, 80, 'Digital logic and circuit design', 'active', NULL),
(31, 'CSC307', 'Graph Theory', 3, NULL, NULL, 9, 82, 'Graph theory concepts', 'active', '[\"CSC102\"]'),
(32, 'CSC315', 'Theory of Programming Languages', 3, NULL, NULL, 9, 82, 'Programming language theory', 'active', '[\"CSC103\"]'),
(33, 'MTH105', 'Multivariable Calculus', 3, NULL, NULL, 9, 82, 'Advanced calculus', 'active', '[\"MTH104\"]'),
(34, 'MTH242', 'Differential Equations', 3, NULL, NULL, 9, 82, 'Differential equations', 'active', '[\"MTH104\"]'),
(35, 'MTH375', 'Numerical Computations', 3, NULL, NULL, 9, 82, 'Numerical methods', 'active', '[\"MTH231\"]'),
(36, 'CSC350', 'Topics in Computer Science I', 3, NULL, NULL, 9, 81, 'Special topics in computer science', 'active', NULL),
(37, 'CSC483', 'Topics in Computer Science II', 3, NULL, NULL, 9, 81, 'Advanced topics in computer science', 'active', NULL),
(38, 'MTH091', 'Pre-Calculus I', 3, NULL, NULL, 9, 83, 'Pre-calculus mathematics', 'active', NULL),
(39, 'MTH092', 'Pre-Calculus II', 3, NULL, NULL, 9, 83, 'Advanced pre-calculus', 'active', NULL),
(40, 'AIC270', 'Programming for Artificial Intelligence', 3, NULL, NULL, 9, 84, 'Programming techniques for AI', 'active', '[\"CSC103\"]'),
(41, 'AIC365', 'Natural Language Processing', 3, NULL, NULL, 9, 84, 'NLP concepts and techniques', 'active', NULL),
(42, 'CSC331', 'Digital Image Processing', 3, NULL, NULL, 9, 84, 'Image processing fundamentals', 'active', '[\"MTH231\"]'),
(43, 'CSC354', 'Machine Learning', 3, NULL, NULL, 9, 84, 'Machine learning algorithms', 'active', NULL),
(44, 'CSC421', 'Robotics', 3, NULL, NULL, 9, 84, 'Robotics principles', 'active', NULL),
(45, 'CSC454', 'Pattern Recognition', 3, NULL, NULL, 9, 84, 'Pattern recognition techniques', 'active', NULL),
(46, 'CSC455', 'Computer Vision', 3, NULL, NULL, 9, 84, 'Computer vision fundamentals', 'active', NULL),
(47, 'CSC367', 'Distributed Data Processing', 3, NULL, NULL, 9, 85, 'Processing large datasets', 'active', NULL),
(48, 'CSC372', 'Exploratory Data Analysis & Visualization', 3, NULL, NULL, 9, 85, 'Data analysis and visualization', 'active', NULL),
(49, 'CSC405', 'Introduction to Artificial Neural Networks', 3, NULL, NULL, 9, 85, 'Neural network fundamentals', 'active', NULL),
(50, 'CSC461', 'Introduction to Data Science', 3, NULL, NULL, 9, 85, 'Data science principles', 'active', '[\"MTH262\"]'),
(51, 'DSC306', 'Data Mining', 3, NULL, NULL, 9, 85, 'Data mining techniques', 'active', NULL),
(52, 'CSC303', 'Mobile Application Development', 3, NULL, NULL, 9, 86, 'Mobile app development', 'active', '[\"CSC241\"]'),
(53, 'CSC336', 'Web Technologies', 3, NULL, NULL, 9, 86, 'Web development technologies', 'active', '[\"CSC241\"]'),
(54, 'CSC337', 'Advanced Web Technologies', 3, NULL, NULL, 9, 86, 'Advanced web development', 'active', '[\"CSC336\"]'),
(55, 'CSC412', 'Visual Programming', 3, NULL, NULL, 9, 86, 'Visual programming concepts', 'active', '[\"CSC241\"]'),
(56, 'CSC417', 'E-Commerce and Digital Marketing', 3, NULL, NULL, 9, 86, 'E-commerce principles', 'active', NULL),
(57, 'CSC418', 'DevOps for Cloud Computing', 3, NULL, NULL, 9, 86, 'DevOps practices', 'active', NULL),
(58, 'CSC335', 'Game Design', 3, NULL, NULL, 9, 87, 'Game design principles', 'active', NULL),
(59, 'CSC353', 'Computer Graphics', 3, NULL, NULL, 9, 87, 'Computer graphics fundamentals', 'active', '[\"MTH231\"]'),
(60, 'CSC356', 'Human Computer Interaction', 3, NULL, NULL, 9, 87, 'HCI concepts', 'active', NULL),
(61, 'CSC495', 'Game Development', 4, NULL, NULL, 9, 87, 'Game development techniques', 'active', '[\"CSC241\"]'),
(62, 'CSC496', 'Game Engine Development', 3, NULL, NULL, 9, 87, 'Game engine architecture', 'active', '[\"CSC495\"]'),
(63, 'CYC205', 'Introduction to Cyber Security', 3, NULL, NULL, 9, 88, 'Cybersecurity fundamentals', 'active', NULL),
(64, 'CYC303', 'Digital Forensics', 3, NULL, NULL, 9, 88, 'Digital forensics techniques', 'active', NULL),
(65, 'CYC307', 'Information Assurance', 3, NULL, NULL, 9, 88, 'Information security assurance', 'active', NULL),
(66, 'CYC365', 'Network Security', 3, NULL, NULL, 9, 88, 'Network security principles', 'active', '[\"CSC340\"]'),
(67, 'CYC386', 'Secure Software Design and Development', 3, NULL, NULL, 9, 88, 'Secure coding practices', 'active', NULL),
(68, 'CYC390', 'Vulnerability Assessment & Reverse Engineering', 3, NULL, NULL, 9, 88, 'Security assessment techniques', 'active', NULL),
(69, 'ECO111', 'Principles of Microeconomics', 3, NULL, NULL, 9, 6, 'Microeconomics fundamentals', 'active', NULL),
(70, 'ECO300', 'Engineering Economics', 3, NULL, NULL, 9, 6, 'Economics for engineers', 'active', NULL),
(71, 'ECO400', 'Business Economics', 3, NULL, NULL, 9, 6, 'Business economics principles', 'active', NULL),
(72, 'ECO403', 'Managerial Economics', 3, NULL, NULL, 9, 6, 'Economics for managers', 'active', NULL),
(73, 'ECO484', 'Project Planning and Monitoring', 3, NULL, NULL, 9, 6, 'Project management techniques', 'active', NULL),
(74, 'HUM220', 'Introduction to Psychology', 3, NULL, NULL, 9, 6, 'Psychology fundamentals', 'active', NULL),
(75, 'HUM221', 'International Relations', 3, NULL, NULL, 9, 6, 'Global relations concepts', 'active', NULL),
(76, 'HUM320', 'Introduction to Sociology', 3, NULL, NULL, 9, 6, 'Sociology principles', 'active', NULL),
(77, 'HUM430', 'French', 3, NULL, NULL, 9, 6, 'French language course', 'active', NULL),
(78, 'HUM431', 'German', 3, NULL, NULL, 9, 6, 'German language course', 'active', NULL),
(79, 'HUM432', 'Arabic', 3, NULL, NULL, 9, 6, 'Arabic language course', 'active', NULL),
(80, 'HUM433', 'Persian', 3, NULL, NULL, 9, 6, 'Persian language course', 'active', NULL),
(81, 'HUM434', 'Chinese', 3, NULL, NULL, 9, 6, 'Chinese language course', 'active', NULL),
(82, 'HUM435', 'Japanese', 3, NULL, NULL, 9, 6, 'Japanese language course', 'active', NULL),
(83, 'MGT100', 'Introduction to Business', 3, NULL, NULL, 9, 6, 'Business fundamentals', 'active', NULL),
(84, 'MGT101', 'Introduction to Management', 3, NULL, NULL, 9, 6, 'Management principles', 'active', NULL),
(85, 'MGT131', 'Financial Accounting', 3, NULL, NULL, 9, 6, 'Accounting basics', 'active', NULL),
(86, 'MGT210', 'Fundamentals of Marketing', 3, NULL, NULL, 9, 6, 'Marketing concepts', 'active', NULL),
(87, 'MGT350', 'Human Resource Management', 3, NULL, NULL, 9, 6, 'HR management techniques', 'active', NULL),
(88, 'MGT513', 'New Product Development', 3, NULL, NULL, 9, 6, 'Product development strategies', 'active', NULL),
(89, 'CSE302', 'Software Quality Engineering', 3, 3, 0, 9, 92, 'Principles and practices of software quality assurance and testing', 'active', '[\"CSC291\"]'),
(90, 'CSE303', 'Software Design and Architecture', 3, 2, 1, 9, 92, 'Software architecture patterns and design principles', 'active', '[\"CSC291\"]'),
(91, 'CSE305', 'Software Requirement Engineering', 3, 3, 0, 9, 92, 'Techniques for eliciting, analyzing, and documenting software requirements', 'active', '[\"CSC291\"]'),
(92, 'CSE325', 'Software Construction and Development', 3, 3, 0, 9, 92, 'Best practices in software construction and development methodologies', 'active', '[\"CSE303\"]'),
(93, 'CSE327', 'Software Re-Engineering', 3, 3, 0, 9, 92, 'Processes and techniques for reengineering legacy systems', 'active', NULL),
(94, 'CSE494', 'Software Project Management', 3, 3, 0, 9, 92, 'Managing software projects using modern methodologies', 'active', '[\"CSC291\"]'),
(95, 'CSE300', 'Software Metrics', 3, 3, 0, 9, 93, 'Measurement and metrics for software processes and products', 'active', '[\"CSC291\"]'),
(96, 'CSE331', 'Software Engineering Economics', 3, 3, 0, 9, 93, 'Economic aspects of software engineering decisions', 'active', NULL),
(97, 'CSE332', 'Information System Audit', 3, 3, 0, 9, 93, 'Auditing principles for information systems', 'active', NULL),
(98, 'CSE333', 'Software Process Improvement', 3, 3, 0, 9, 93, 'Methods for improving software development processes', 'active', NULL),
(99, 'CSE334', 'Reverse Engineering of Source Code', 3, 2, 1, 9, 93, 'Techniques for analyzing and understanding existing codebases', 'active', NULL),
(100, 'CSE344', 'Semantic Web', 3, 2, 1, 9, 93, 'Technologies for creating machine-readable web content', 'active', NULL),
(101, 'CSE350', 'Topics in Software Engineering I', 3, 3, 0, 9, 93, 'Special topics in software engineering (requires HOD approval)', 'active', NULL),
(102, 'CSE354', 'Design Patterns', 3, 2, 1, 9, 93, 'Common software design patterns and their applications', 'active', NULL),
(103, 'CSE360', 'Software Safety Critical Systems', 3, 3, 0, 9, 93, 'Development of safety-critical software systems', 'active', NULL),
(104, 'CSE361', 'Software Fault Tolerance', 3, 3, 0, 9, 93, 'Techniques for building fault-tolerant software systems', 'active', NULL),
(105, 'CSE482', 'Automated Software Testing', 3, 2, 1, 9, 93, 'Tools and techniques for automated software testing', 'active', NULL),
(106, 'CSE483', 'Topics in Software Engineering II', 3, 3, 0, 9, 93, 'Advanced topics in software engineering (requires HOD approval)', 'active', NULL),
(107, 'CSE356', 'Formal Methods', 3, 3, 0, 9, 94, 'Mathematically rigorous techniques for software specification and verification', 'active', '[\"CSC291\"]'),
(108, 'CSE357', 'Business Process Engineering', 3, 3, 0, 9, 94, 'Modeling and improving business processes', 'active', NULL),
(109, 'CSC451', 'Introduction to Modeling and Simulation', 3, 2, 1, 9, 94, 'Fundamentals of modeling and simulation techniques', 'active', '[\"CSC211\"]'),
(110, 'CSC456', 'Stochastic Processes', 3, 3, 0, 9, 94, 'Probability models for random processes', 'active', NULL),
(111, 'MTH467', 'Operations Research', 3, 3, 0, 9, 94, 'Mathematical optimization techniques for decision making', 'active', NULL),
(112, 'MTH100', 'Mathematics I', 3, 3, 0, 9, 83, 'Foundation mathematics course for pre-medical students', 'active', NULL),
(113, 'MTH101', 'Calculus I', 3, 3, 0, 9, 83, 'Introductory calculus course for pre-medical students', 'active', NULL),
(114, 'CSC470', 'Advanced Database Systems', 3, 2, 1, 9, 95, 'Advanced topics in database systems including query optimization, transaction processing, and distributed databases', 'active', '[\"CSC270\"]'),
(115, 'CSC475', 'NoSQL Databases', 3, 2, 1, 9, 95, 'Study of non-relational database systems including document, key-value, column-family, and graph databases', 'active', '[\"CSC270\"]'),
(116, 'CSE480', 'Database Administration', 3, 2, 1, 9, 95, 'Database installation, configuration, tuning, backup/recovery, and security administration', 'active', '[\"CSC270\"]'),
(117, 'CSC477', 'Big Data Technologies', 3, 2, 1, 9, 96, 'Technologies for processing large datasets including Hadoop, Spark, and distributed file systems', 'active', '[\"CSC270\"]'),
(118, 'CSE485', 'Data Warehousing and Business Intelligence', 3, 2, 1, 9, 96, 'Design and implementation of data warehouses and business intelligence systems', 'active', '[\"CSC270\"]'),
(119, 'CSE490', 'Database Security', 3, 3, 0, 9, 96, 'Security models, encryption, access control, and auditing for database systems', 'active', '[\"CSC270\",\"CSC432\"]'),
(120, 'BIO231', 'Fundamentals of Genetics', 4, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(121, 'BIO310', 'Introduction to Bioinformatics', 4, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(122, 'CSC110', 'Professional Practices for IT', 3, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(123, 'CSC371', 'Database Systems I', 4, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(124, 'EEE440', 'Computer Architecture', 3, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(125, 'CSC322', 'Operating Systems', 3, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(126, 'CSC339', 'Data Communications and Computer Networks', 3, NULL, NULL, 9, NULL, NULL, 'active', NULL),
(127, 'CSC321', 'Microprocessor and Assembly Language', 3, NULL, NULL, 9, NULL, NULL, 'active', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `course_categories`
--

CREATE TABLE `course_categories` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `program_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course_categories`
--

INSERT INTO `course_categories` (`id`, `name`, `description`, `program_id`) VALUES
(6, 'University Electives', 'Electives from other departments', NULL),
(11, 'Computing Core', 'Fundamental computing courses required for all CS students', NULL),
(12, 'Mathematics & Science', 'Foundation courses in mathematics and science', NULL),
(13, 'General Education', 'University required general education courses', NULL),
(14, 'University Electives', 'Elective courses from across the university', NULL),
(15, 'CS Core', 'Core computer science courses', NULL),
(16, 'CS Electives', 'Computer science elective courses', NULL),
(17, 'CS Supporting', 'Supporting courses for computer science', NULL),
(18, 'Deficiency', 'Courses for pre-medical students', NULL),
(19, 'Track - AI', 'Artificial Intelligence track courses', NULL),
(20, 'Track - Data Science', 'Data Science track courses', NULL),
(21, 'Track - Software Dev', 'Software Development track courses', NULL),
(22, 'Track - Game Dev', 'Game Development track courses', NULL),
(23, 'Track - Cyber Security', 'Cyber Security track courses', NULL),
(40, 'University Electives', 'Elective courses from across the university', NULL),
(66, 'University Electives', 'Elective courses from across the university', NULL),
(76, 'Computing Core', 'Fundamental computing courses required for all CS students', 8),
(77, 'Mathematics & Science', 'Foundation courses in mathematics and science', 8),
(78, 'General Education', 'University required general education courses', 8),
(79, 'University Electives', 'Elective courses from across the university', NULL),
(80, 'CS Core', 'Core computer science courses', 8),
(81, 'CS Electives', 'Computer science elective courses', 8),
(82, 'CS Supporting', 'Supporting courses for computer science', 8),
(83, 'Deficiency', 'Courses for pre-medical students', 8),
(84, 'Track - AI', 'Artificial Intelligence track courses', 8),
(85, 'Track - Data Science', 'Data Science track courses', 8),
(86, 'Track - Software Dev', 'Software Development track courses', 8),
(87, 'Track - Game Dev', 'Game Development track courses', 8),
(88, 'Track - Cyber Security', 'Cyber Security track courses', 8),
(92, 'SE Core', 'Core software engineering courses', 9),
(93, 'SE Electives', 'Software engineering elective courses', 9),
(94, 'SE Supporting', 'Supporting courses for software engineering', 9),
(95, 'Database Core', 'Advanced database systems courses', 9),
(96, 'Database Electives', 'Specialized database elective courses', 9);

-- --------------------------------------------------------

--
-- Table structure for table `course_offerings`
--

CREATE TABLE `course_offerings` (
  `id` int NOT NULL,
  `course_id` int NOT NULL,
  `section_id` int NOT NULL,
  `faculty_id` int NOT NULL,
  `semester` int NOT NULL,
  `max_students` int DEFAULT '40',
  `status` enum('open','closed','completed') DEFAULT 'open'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course_offerings`
--

INSERT INTO `course_offerings` (`id`, `course_id`, `section_id`, `faculty_id`, `semester`, `max_students`, `status`) VALUES
(1, 27, 1, 1, 8, 40, 'open'),
(2, 11, 1, 1, 8, 40, 'open'),
(3, 74, 1, 3, 8, 40, 'open'),
(4, 87, 1, 2, 8, 40, 'open'),
(5, 16, 66, 1, 1, 40, 'completed'),
(6, 1, 66, 1, 1, 40, 'completed'),
(7, 18, 66, 1, 1, 40, 'completed'),
(8, 21, 66, 1, 1, 40, 'completed'),
(9, 12, 66, 1, 1, 40, 'completed'),
(10, 15, 66, 1, 1, 40, 'completed'),
(12, 120, 67, 1, 2, 40, 'completed'),
(13, 2, 67, 1, 2, 40, 'completed'),
(14, 122, 67, 1, 2, 40, 'completed'),
(15, 20, 67, 1, 2, 40, 'completed'),
(16, 22, 67, 1, 2, 40, 'completed'),
(17, 33, 67, 1, 2, 40, 'completed'),
(19, 121, 68, 1, 3, 40, 'completed'),
(20, 4, 68, 1, 3, 40, 'completed'),
(21, 30, 68, 1, 3, 40, 'completed'),
(22, 19, 68, 1, 3, 40, 'completed'),
(23, 13, 68, 1, 3, 40, 'completed'),
(24, 14, 68, 1, 3, 40, 'completed'),
(26, 3, 69, 1, 4, 40, 'completed'),
(27, 6, 69, 1, 4, 40, 'completed'),
(28, 123, 69, 1, 4, 40, 'completed'),
(29, 124, 69, 1, 4, 40, 'completed'),
(30, 34, 69, 1, 4, 40, 'completed'),
(33, 24, 70, 1, 5, 40, 'completed'),
(34, 25, 70, 1, 5, 40, 'completed'),
(35, 125, 70, 1, 5, 40, 'completed'),
(36, 53, 70, 1, 5, 40, 'completed'),
(37, 55, 70, 1, 5, 40, 'completed'),
(40, 126, 71, 1, 6, 40, 'completed'),
(41, 28, 71, 1, 6, 40, 'completed'),
(42, 29, 71, 1, 6, 40, 'completed'),
(43, 115, 71, 1, 6, 40, 'completed'),
(44, 61, 71, 1, 6, 40, 'completed'),
(47, 52, 72, 1, 7, 40, 'completed'),
(48, 127, 72, 1, 7, 40, 'completed'),
(49, 43, 72, 1, 7, 40, 'completed'),
(50, 60, 72, 1, 7, 40, 'completed'),
(51, 10, 72, 1, 7, 40, 'completed'),
(60, 16, 73, 1, 1, 40, 'completed'),
(61, 1, 73, 1, 1, 40, 'completed'),
(62, 18, 73, 3, 1, 40, 'completed'),
(63, 21, 73, 3, 1, 40, 'completed'),
(64, 15, 73, 1, 1, 40, 'completed'),
(67, 2, 74, 1, 2, 40, 'completed'),
(68, 30, 74, 1, 2, 40, 'completed'),
(69, 20, 74, 3, 2, 40, 'completed'),
(70, 22, 74, 3, 2, 40, 'completed'),
(71, 84, 74, 2, 2, 40, 'completed'),
(74, 24, 137, 1, 7, 40, 'open'),
(75, 52, 137, 1, 7, 40, 'open'),
(76, 7, 137, 1, 7, 40, 'open'),
(77, 28, 137, 1, 7, 40, 'open'),
(78, 29, 137, 1, 7, 40, 'open'),
(79, 34, 137, 1, 7, 40, 'open');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `established_date` date DEFAULT '1998-01-01',
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `code`, `established_date`, `status`) VALUES
(9, 'Computer Science', 'CS', '1998-01-01', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `faculty`
--

CREATE TABLE `faculty` (
  `id` int NOT NULL,
  `employee_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `department_id` int NOT NULL,
  `designation` varchar(50) NOT NULL,
  `status` enum('active','on_leave','retired') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculty`
--

INSERT INTO `faculty` (`id`, `employee_id`, `name`, `email`, `department_id`, `designation`, `status`) VALUES
(1, 'CS-001', 'Yasar Khan', 'yasar.khan@isb.ciit.edu.pk', 9, 'Assistant Professor', 'active'),
(2, 'CS-002', 'Abida Jadoon', 'abida.jadoon@isb.ciit.edu.pk', 9, 'Lecturer', 'active'),
(3, 'HUM-001', 'Sara Rafaq', 'sara.rafaq@isb.ciit.edu.pk', 9, 'Visiting Faculty', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `final_grades`
--

CREATE TABLE `final_grades` (
  `id` int NOT NULL,
  `student_course_id` int NOT NULL,
  `total_marks` decimal(5,2) NOT NULL,
  `grade` varchar(2) NOT NULL,
  `grade_points` decimal(3,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `final_grades`
--

INSERT INTO `final_grades` (`id`, `student_course_id`, `total_marks`, `grade`, `grade_points`) VALUES
(1, 5, 82.00, 'A-', 3.66),
(2, 6, 76.00, 'B+', 3.33),
(3, 7, 72.00, 'B', 3.00),
(4, 8, 86.00, 'A', 4.00),
(5, 9, 73.00, 'B', 3.00),
(6, 10, 74.00, 'B', 3.00),
(8, 12, 85.00, 'A', 4.00),
(9, 13, 71.00, 'B', 3.00),
(10, 14, 85.00, 'A', 4.00),
(11, 15, 90.00, 'A', 4.00),
(12, 16, 82.00, 'A-', 3.66),
(13, 17, 85.00, 'A', 4.00),
(15, 19, 87.00, 'A', 4.00),
(16, 20, 93.00, 'A', 4.00),
(17, 21, 76.00, 'B+', 3.33),
(18, 22, 85.00, 'A', 4.00),
(19, 23, 81.00, 'A-', 3.66),
(20, 24, 90.00, 'A', 4.00),
(22, 26, 89.00, 'A', 4.00),
(23, 27, 85.00, 'A', 4.00),
(24, 30, 92.00, 'A', 4.00),
(25, 28, 86.00, 'A', 4.00),
(26, 29, 89.00, 'A', 4.00),
(29, 33, 91.00, 'A', 4.00),
(30, 34, 80.00, 'A-', 3.66),
(31, 36, 94.00, 'A', 4.00),
(32, 37, 86.00, 'A', 4.00),
(33, 35, 77.00, 'B+', 3.33),
(36, 41, 85.00, 'A', 4.00),
(37, 42, 60.00, 'C-', 1.66),
(38, 44, 94.00, 'A', 4.00),
(39, 43, 87.00, 'A', 4.00),
(40, 40, 85.00, 'A', 4.00),
(43, 51, 91.00, 'A', 4.00),
(44, 49, 85.00, 'A', 4.00),
(45, 47, 92.00, 'A', 4.00),
(46, 50, 80.00, 'A-', 3.66),
(47, 48, 85.00, 'A', 4.00),
(50, 55, 77.00, 'B+', 3.33),
(51, 56, 78.00, 'B+', 3.33),
(52, 57, 65.00, 'C+', 2.33),
(53, 58, 80.00, 'A-', 3.66),
(54, 59, 68.00, 'B-', 2.66),
(57, 62, 80.00, 'A-', 3.66),
(58, 63, 64.00, 'C+', 2.33),
(59, 64, 79.00, 'B+', 3.33),
(60, 65, 81.00, 'A-', 3.66),
(61, 66, 83.00, 'A-', 3.66);

-- --------------------------------------------------------

--
-- Table structure for table `prerequisites`
--

CREATE TABLE `prerequisites` (
  `id` int NOT NULL,
  `course_id` int NOT NULL,
  `prerequisite_course_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE `programs` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `department_id` int NOT NULL,
  `degree_level` enum('undergraduate') DEFAULT 'undergraduate',
  `total_semesters` int NOT NULL,
  `min_credits` int NOT NULL,
  `status` enum('active','inactive') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programs`
--

INSERT INTO `programs` (`id`, `name`, `code`, `department_id`, `degree_level`, `total_semesters`, `min_credits`, `status`) VALUES
(8, 'Bachelor of Science in Computer Science', 'BCS', 9, 'undergraduate', 8, 133, 'active'),
(9, 'Bachelor of Science in Software Engineering', 'BSE', 9, 'undergraduate', 8, 136, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `program_courses`
--

CREATE TABLE `program_courses` (
  `id` int NOT NULL,
  `program_id` int NOT NULL,
  `course_id` int NOT NULL,
  `semester` int NOT NULL,
  `course_type` enum('compulsory','elective') NOT NULL,
  `track` varchar(50) DEFAULT NULL COMMENT 'Specialization track if applicable'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `program_courses`
--

INSERT INTO `program_courses` (`id`, `program_id`, `course_id`, `semester`, `course_type`, `track`) VALUES
(1, 8, 1, 1, 'compulsory', NULL),
(2, 8, 2, 1, 'compulsory', NULL),
(3, 8, 3, 2, 'compulsory', NULL),
(4, 8, 4, 3, 'compulsory', NULL),
(5, 8, 5, 4, 'compulsory', NULL),
(6, 8, 6, 4, 'compulsory', NULL),
(7, 8, 7, 5, 'compulsory', NULL),
(8, 8, 8, 6, 'compulsory', NULL),
(9, 8, 9, 7, 'compulsory', NULL),
(10, 8, 10, 7, 'compulsory', NULL),
(11, 8, 11, 8, 'compulsory', NULL),
(12, 8, 12, 1, 'compulsory', NULL),
(13, 8, 13, 2, 'compulsory', NULL),
(14, 8, 14, 3, 'compulsory', NULL),
(15, 8, 15, 1, 'compulsory', NULL),
(16, 8, 18, 1, 'compulsory', NULL),
(17, 8, 19, 2, 'compulsory', NULL),
(18, 8, 20, 3, 'compulsory', NULL),
(19, 8, 21, 4, 'compulsory', NULL),
(20, 8, 22, 5, 'compulsory', NULL),
(21, 8, 16, 1, 'compulsory', NULL),
(22, 8, 17, 7, 'compulsory', NULL),
(23, 8, 24, 5, 'compulsory', NULL),
(24, 8, 25, 4, 'compulsory', NULL),
(25, 8, 26, 3, 'compulsory', NULL),
(26, 8, 27, 6, 'compulsory', NULL),
(27, 8, 28, 7, 'compulsory', NULL),
(28, 8, 29, 6, 'compulsory', NULL),
(29, 8, 30, 2, 'compulsory', NULL),
(30, 8, 31, 6, 'elective', NULL),
(31, 8, 32, 5, 'elective', NULL),
(32, 8, 33, 3, 'elective', NULL),
(33, 8, 34, 4, 'elective', NULL),
(34, 8, 35, 7, 'elective', NULL),
(35, 8, 36, 6, 'elective', NULL),
(36, 8, 37, 7, 'elective', NULL),
(37, 8, 69, 5, 'elective', NULL),
(38, 8, 70, 6, 'elective', NULL),
(39, 8, 71, 7, 'elective', NULL),
(40, 8, 72, 8, 'elective', NULL),
(41, 8, 73, 8, 'elective', NULL),
(42, 8, 74, 5, 'elective', NULL),
(43, 8, 75, 6, 'elective', NULL),
(44, 8, 76, 7, 'elective', NULL),
(45, 8, 77, 5, 'elective', NULL),
(46, 8, 78, 6, 'elective', NULL),
(47, 8, 79, 7, 'elective', NULL),
(48, 8, 80, 8, 'elective', NULL),
(49, 8, 81, 5, 'elective', NULL),
(50, 8, 82, 6, 'elective', NULL),
(51, 8, 83, 5, 'elective', NULL),
(52, 8, 84, 6, 'elective', NULL),
(53, 8, 85, 7, 'elective', NULL),
(54, 8, 86, 8, 'elective', NULL),
(55, 8, 87, 7, 'elective', NULL),
(56, 8, 88, 8, 'elective', NULL),
(57, 8, 40, 5, 'elective', NULL),
(58, 8, 41, 6, 'elective', NULL),
(59, 8, 42, 7, 'elective', NULL),
(60, 8, 43, 6, 'elective', NULL),
(61, 8, 44, 7, 'elective', NULL),
(62, 8, 45, 8, 'elective', NULL),
(63, 8, 46, 8, 'elective', NULL),
(64, 8, 47, 5, 'elective', NULL),
(65, 8, 48, 6, 'elective', NULL),
(66, 8, 49, 7, 'elective', NULL),
(67, 8, 50, 6, 'elective', NULL),
(68, 8, 51, 7, 'elective', NULL),
(69, 8, 52, 5, 'elective', NULL),
(70, 8, 53, 6, 'elective', NULL),
(71, 8, 54, 7, 'elective', NULL),
(72, 8, 55, 6, 'elective', NULL),
(73, 8, 56, 7, 'elective', NULL),
(74, 8, 57, 8, 'elective', NULL),
(75, 8, 58, 5, 'elective', NULL),
(76, 8, 59, 6, 'elective', NULL),
(77, 8, 60, 7, 'elective', NULL),
(78, 8, 61, 7, 'elective', NULL),
(79, 8, 62, 8, 'elective', NULL),
(80, 8, 63, 5, 'elective', NULL),
(81, 8, 64, 6, 'elective', NULL),
(82, 8, 65, 7, 'elective', NULL),
(83, 8, 66, 6, 'elective', NULL),
(84, 8, 67, 7, 'elective', NULL),
(85, 8, 68, 8, 'elective', NULL),
(86, 8, 38, 1, 'compulsory', NULL),
(87, 8, 39, 2, 'compulsory', NULL),
(88, 9, 114, 5, 'compulsory', NULL),
(89, 9, 115, 6, 'compulsory', NULL),
(90, 9, 116, 6, 'compulsory', NULL),
(91, 9, 117, 7, 'elective', 'Database Systems'),
(92, 9, 118, 7, 'elective', 'Database Systems'),
(93, 9, 119, 8, 'elective', 'Database Systems');

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `id` int NOT NULL,
  `name` varchar(10) NOT NULL COMMENT 'A, B, C etc.',
  `batch_id` int NOT NULL,
  `semester` int NOT NULL,
  `advisor_id` int DEFAULT NULL,
  `status` enum('active','completed') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`id`, `name`, `batch_id`, `semester`, `advisor_id`, `status`) VALUES
(1, 'A', 1, 8, NULL, 'active'),
(2, 'A', 2, 1, NULL, 'active'),
(3, 'A', 2, 2, NULL, 'active'),
(4, 'A', 2, 3, NULL, 'active'),
(5, 'A', 2, 4, NULL, 'active'),
(6, 'A', 2, 5, NULL, 'active'),
(7, 'A', 2, 6, NULL, 'active'),
(8, 'A', 2, 7, NULL, 'active'),
(9, 'A', 2, 8, NULL, 'active'),
(10, 'A', 3, 1, NULL, 'active'),
(11, 'A', 3, 2, NULL, 'active'),
(12, 'A', 3, 3, NULL, 'active'),
(13, 'A', 3, 4, NULL, 'active'),
(14, 'A', 3, 5, NULL, 'active'),
(15, 'A', 3, 6, NULL, 'active'),
(16, 'A', 3, 7, NULL, 'active'),
(17, 'A', 3, 8, NULL, 'active'),
(18, 'A', 4, 1, NULL, 'active'),
(19, 'A', 4, 2, NULL, 'active'),
(20, 'A', 4, 3, NULL, 'active'),
(21, 'A', 4, 4, NULL, 'active'),
(22, 'A', 4, 5, NULL, 'active'),
(23, 'A', 4, 6, NULL, 'active'),
(24, 'A', 4, 7, NULL, 'active'),
(25, 'A', 4, 8, NULL, 'active'),
(26, 'A', 5, 1, NULL, 'active'),
(27, 'A', 5, 2, NULL, 'active'),
(28, 'A', 5, 3, NULL, 'active'),
(29, 'A', 5, 4, NULL, 'active'),
(30, 'A', 5, 5, NULL, 'active'),
(31, 'A', 5, 6, NULL, 'active'),
(32, 'A', 5, 7, NULL, 'active'),
(33, 'A', 5, 8, NULL, 'active'),
(34, 'A', 6, 1, NULL, 'active'),
(35, 'A', 6, 2, NULL, 'active'),
(36, 'A', 6, 3, NULL, 'active'),
(37, 'A', 6, 4, NULL, 'active'),
(38, 'A', 6, 5, NULL, 'active'),
(39, 'A', 6, 6, NULL, 'active'),
(40, 'A', 6, 7, NULL, 'active'),
(41, 'A', 6, 8, NULL, 'active'),
(42, 'A', 7, 1, NULL, 'active'),
(43, 'A', 7, 2, NULL, 'active'),
(44, 'A', 7, 3, NULL, 'active'),
(45, 'A', 7, 4, NULL, 'active'),
(46, 'A', 7, 5, NULL, 'active'),
(47, 'A', 7, 6, NULL, 'active'),
(48, 'A', 7, 7, NULL, 'active'),
(49, 'A', 7, 8, NULL, 'active'),
(50, 'A', 8, 1, NULL, 'active'),
(51, 'A', 8, 2, NULL, 'active'),
(52, 'A', 8, 3, NULL, 'active'),
(53, 'A', 8, 4, NULL, 'active'),
(54, 'A', 8, 5, NULL, 'active'),
(55, 'A', 8, 6, NULL, 'active'),
(56, 'A', 8, 7, NULL, 'active'),
(57, 'A', 8, 8, NULL, 'active'),
(58, 'A', 9, 1, NULL, 'active'),
(59, 'A', 9, 2, NULL, 'active'),
(60, 'A', 9, 3, NULL, 'active'),
(61, 'A', 9, 4, NULL, 'active'),
(62, 'A', 9, 5, NULL, 'active'),
(63, 'A', 9, 6, NULL, 'active'),
(64, 'A', 9, 7, NULL, 'active'),
(65, 'A', 9, 8, NULL, 'active'),
(66, 'A', 1, 1, NULL, 'completed'),
(67, 'A', 1, 2, NULL, 'completed'),
(68, 'A', 1, 3, NULL, 'completed'),
(69, 'A', 1, 4, NULL, 'completed'),
(70, 'A', 1, 5, NULL, 'completed'),
(71, 'A', 1, 6, NULL, 'completed'),
(72, 'A', 1, 7, NULL, 'completed'),
(73, 'A', 10, 1, NULL, 'active'),
(74, 'A', 10, 2, NULL, 'active'),
(75, 'A', 10, 3, NULL, 'active'),
(76, 'A', 10, 4, NULL, 'active'),
(77, 'A', 10, 5, NULL, 'active'),
(78, 'A', 10, 6, NULL, 'active'),
(79, 'C', 10, 7, NULL, 'active'),
(80, 'A', 10, 8, NULL, 'active'),
(81, 'A', 11, 1, NULL, 'active'),
(82, 'A', 11, 2, NULL, 'active'),
(83, 'A', 11, 3, NULL, 'active'),
(84, 'A', 11, 4, NULL, 'active'),
(85, 'A', 11, 5, NULL, 'active'),
(86, 'A', 11, 6, NULL, 'active'),
(87, 'A', 11, 7, NULL, 'active'),
(88, 'A', 11, 8, NULL, 'active'),
(89, 'A', 12, 1, NULL, 'active'),
(90, 'A', 12, 2, NULL, 'active'),
(91, 'A', 12, 3, NULL, 'active'),
(92, 'A', 12, 4, NULL, 'active'),
(93, 'A', 12, 5, NULL, 'active'),
(94, 'A', 12, 6, NULL, 'active'),
(95, 'A', 12, 7, NULL, 'active'),
(96, 'A', 12, 8, NULL, 'active'),
(97, 'A', 13, 1, NULL, 'active'),
(98, 'A', 13, 2, NULL, 'active'),
(99, 'A', 13, 3, NULL, 'active'),
(100, 'A', 13, 4, NULL, 'active'),
(101, 'A', 13, 5, NULL, 'active'),
(102, 'A', 13, 6, NULL, 'active'),
(103, 'A', 13, 7, NULL, 'active'),
(104, 'A', 13, 8, NULL, 'active'),
(105, 'A', 14, 1, NULL, 'active'),
(106, 'A', 14, 2, NULL, 'active'),
(107, 'A', 14, 3, NULL, 'active'),
(108, 'A', 14, 4, NULL, 'active'),
(109, 'A', 14, 5, NULL, 'active'),
(110, 'A', 14, 6, NULL, 'active'),
(111, 'A', 14, 7, NULL, 'active'),
(112, 'A', 14, 8, NULL, 'active'),
(113, 'A', 15, 1, NULL, 'active'),
(114, 'A', 15, 2, NULL, 'active'),
(115, 'A', 15, 3, NULL, 'active'),
(116, 'A', 15, 4, NULL, 'active'),
(117, 'A', 15, 5, NULL, 'active'),
(118, 'A', 15, 6, NULL, 'active'),
(119, 'A', 15, 7, NULL, 'active'),
(120, 'A', 15, 8, NULL, 'active'),
(121, 'A', 16, 1, NULL, 'active'),
(122, 'A', 16, 2, NULL, 'active'),
(123, 'A', 16, 3, NULL, 'active'),
(124, 'A', 16, 4, NULL, 'active'),
(125, 'A', 16, 5, NULL, 'active'),
(126, 'A', 16, 6, NULL, 'active'),
(127, 'A', 16, 7, NULL, 'active'),
(128, 'A', 16, 8, NULL, 'active'),
(129, 'A', 17, 1, NULL, 'active'),
(130, 'A', 17, 2, NULL, 'active'),
(131, 'A', 17, 3, NULL, 'active'),
(132, 'A', 17, 4, NULL, 'active'),
(133, 'A', 17, 5, NULL, 'active'),
(134, 'A', 17, 6, NULL, 'active'),
(135, 'A', 17, 7, NULL, 'active'),
(136, 'A', 17, 8, NULL, 'active'),
(137, 'C', 1, 7, NULL, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int NOT NULL,
  `regno` varchar(20) NOT NULL COMMENT 'FA21-BCS-001 format',
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `cnic` varchar(15) NOT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `program_id` int NOT NULL,
  `batch_id` int NOT NULL,
  `current_semester` int DEFAULT '1',
  `status` enum('active','graduated','suspended','left') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `regno`, `name`, `email`, `cnic`, `phone`, `program_id`, `batch_id`, `current_semester`, `status`) VALUES
(1, 'FA21-BCS-154', 'Shah Zaib', 'shahzaib63219@gmail.com', '13101-4760634-7', NULL, 8, 1, 8, 'active'),
(2, 'SP22-BCS-120', 'Khawaja Uneeb Ullah', 'SP22-BCS-120@student.ciit-atd.edu.pk', '13302-5229875-1', NULL, 8, 10, 7, 'active'),
(3, 'FA21-BCS-152', 'Shabab Hussain', 'shabab.hussain@example.com', '21303-0452113-7', NULL, 8, 1, 8, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `student_courses`
--

CREATE TABLE `student_courses` (
  `id` int NOT NULL,
  `student_id` int NOT NULL,
  `course_offering_id` int NOT NULL,
  `registration_date` date NOT NULL,
  `status` enum('registered','dropped','completed') DEFAULT 'registered'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_courses`
--

INSERT INTO `student_courses` (`id`, `student_id`, `course_offering_id`, `registration_date`, `status`) VALUES
(1, 1, 1, '2025-01-15', 'registered'),
(2, 1, 2, '2025-01-15', 'registered'),
(3, 1, 3, '2025-01-15', 'registered'),
(4, 1, 4, '2025-01-15', 'registered'),
(5, 1, 6, '2021-09-01', 'completed'),
(6, 1, 9, '2021-09-01', 'completed'),
(7, 1, 10, '2021-09-01', 'completed'),
(8, 1, 5, '2021-09-01', 'completed'),
(9, 1, 7, '2021-09-01', 'completed'),
(10, 1, 8, '2021-09-01', 'completed'),
(12, 1, 13, '2022-02-01', 'completed'),
(13, 1, 15, '2022-02-01', 'completed'),
(14, 1, 16, '2022-02-01', 'completed'),
(15, 1, 17, '2022-02-01', 'completed'),
(16, 1, 12, '2022-02-01', 'completed'),
(17, 1, 14, '2022-02-01', 'completed'),
(19, 1, 20, '2022-09-01', 'completed'),
(20, 1, 23, '2022-09-01', 'completed'),
(21, 1, 24, '2022-09-01', 'completed'),
(22, 1, 22, '2022-09-01', 'completed'),
(23, 1, 21, '2022-09-01', 'completed'),
(24, 1, 19, '2022-09-01', 'completed'),
(26, 1, 26, '2023-02-01', 'completed'),
(27, 1, 27, '2023-02-01', 'completed'),
(28, 1, 28, '2023-02-01', 'completed'),
(29, 1, 29, '2023-02-01', 'completed'),
(30, 1, 30, '2023-02-01', 'completed'),
(33, 1, 33, '2023-09-01', 'completed'),
(34, 1, 34, '2023-09-01', 'completed'),
(35, 1, 35, '2023-09-01', 'completed'),
(36, 1, 36, '2023-09-01', 'completed'),
(37, 1, 37, '2023-09-01', 'completed'),
(40, 1, 40, '2024-02-01', 'completed'),
(41, 1, 41, '2024-02-01', 'completed'),
(42, 1, 42, '2024-02-01', 'completed'),
(43, 1, 43, '2024-02-01', 'completed'),
(44, 1, 44, '2024-02-01', 'completed'),
(47, 1, 47, '2024-09-01', 'completed'),
(48, 1, 48, '2024-09-01', 'completed'),
(49, 1, 49, '2024-09-01', 'completed'),
(50, 1, 50, '2024-09-01', 'completed'),
(51, 1, 51, '2024-09-01', 'completed'),
(55, 2, 60, '2022-02-01', 'completed'),
(56, 2, 61, '2022-02-01', 'completed'),
(57, 2, 62, '2022-02-01', 'completed'),
(58, 2, 63, '2022-02-01', 'completed'),
(59, 2, 64, '2022-02-01', 'completed'),
(62, 2, 67, '2022-09-01', 'completed'),
(63, 2, 68, '2022-09-01', 'completed'),
(64, 2, 69, '2022-09-01', 'completed'),
(65, 2, 70, '2022-09-01', 'completed'),
(66, 2, 71, '2022-09-01', 'completed'),
(69, 2, 74, '2025-04-13', 'registered'),
(70, 2, 75, '2025-04-13', 'registered'),
(71, 2, 76, '2025-04-13', 'registered'),
(72, 2, 77, '2025-04-13', 'registered'),
(73, 2, 78, '2025-04-13', 'registered'),
(74, 2, 79, '2025-04-13', 'registered');

-- --------------------------------------------------------

--
-- Table structure for table `student_login`
--

CREATE TABLE `student_login` (
  `id` int NOT NULL,
  `student_id` int NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `last_login` datetime DEFAULT NULL,
  `status` enum('active','locked') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_login`
--

INSERT INTO `student_login` (`id`, `student_id`, `username`, `password`, `last_login`, `status`) VALUES
(1, 1, 'fa21-bcs-154', '$2y$10$F7TqHcX7/COQtQj0pTfCU.6T43F9XjOa2vj1x6amOw5.mx/eoxnEe', NULL, 'active'),
(53, 2, 'SP22-BCS-120', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', NULL, 'active'),
(54, 3, 'fa21-bcs-152', '$2y$10$examplehashedpassword', NULL, 'active');

-- --------------------------------------------------------

--
-- Table structure for table `student_results`
--

CREATE TABLE `student_results` (
  `id` int NOT NULL,
  `student_course_id` int NOT NULL,
  `assessment_id` int NOT NULL,
  `obtained_marks` decimal(5,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `timetable`
--

CREATE TABLE `timetable` (
  `id` int NOT NULL,
  `course_offering_id` int NOT NULL,
  `time_slot_id` int NOT NULL,
  `room` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timetable`
--

INSERT INTO `timetable` (`id`, `course_offering_id`, `time_slot_id`, `room`) VALUES
(1, 4, 2, 'S207'),
(2, 3, 4, 'S203'),
(3, 4, 10, 'C205'),
(4, 3, 11, 'S311'),
(5, 1, 18, 'C202'),
(6, 1, 27, 'C-103 (Lab 6)'),
(7, 1, 28, 'C-103 (Lab 6)');

-- --------------------------------------------------------

--
-- Table structure for table `time_slots`
--

CREATE TABLE `time_slots` (
  `id` int NOT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `slot_type` enum('lecture','lab','tutorial') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `time_slots`
--

INSERT INTO `time_slots` (`id`, `day`, `start_time`, `end_time`, `slot_type`) VALUES
(1, 'Monday', '09:00:00', '10:30:00', 'lecture'),
(2, 'Monday', '10:30:00', '12:00:00', 'lecture'),
(3, 'Monday', '12:00:00', '14:00:00', 'lecture'),
(4, 'Monday', '14:00:00', '15:30:00', 'lecture'),
(5, 'Monday', '15:30:00', '17:00:00', 'lecture'),
(6, 'Monday', '17:00:00', '18:30:00', 'lecture'),
(7, 'Monday', '18:30:00', '20:00:00', 'lecture'),
(8, 'Monday', '20:00:00', '21:30:00', 'lecture'),
(9, 'Tuesday', '09:00:00', '10:30:00', 'lecture'),
(10, 'Tuesday', '10:30:00', '12:00:00', 'lecture'),
(11, 'Tuesday', '12:00:00', '14:00:00', 'lecture'),
(12, 'Tuesday', '14:00:00', '15:30:00', 'lecture'),
(13, 'Tuesday', '15:30:00', '17:00:00', 'lecture'),
(14, 'Tuesday', '17:00:00', '18:30:00', 'lecture'),
(15, 'Tuesday', '18:30:00', '20:00:00', 'lecture'),
(16, 'Tuesday', '20:00:00', '21:30:00', 'lecture'),
(17, 'Wednesday', '09:00:00', '10:30:00', 'lecture'),
(18, 'Wednesday', '10:30:00', '12:00:00', 'lecture'),
(19, 'Wednesday', '12:00:00', '14:00:00', 'lecture'),
(20, 'Wednesday', '14:00:00', '15:30:00', 'lecture'),
(21, 'Wednesday', '15:30:00', '17:00:00', 'lecture'),
(22, 'Wednesday', '17:00:00', '18:30:00', 'lecture'),
(23, 'Wednesday', '18:30:00', '20:00:00', 'lecture'),
(24, 'Wednesday', '20:00:00', '21:30:00', 'lecture'),
(25, 'Thursday', '09:00:00', '10:30:00', 'lecture'),
(26, 'Thursday', '10:30:00', '12:00:00', 'lecture'),
(27, 'Thursday', '12:00:00', '14:00:00', 'lecture'),
(28, 'Thursday', '14:00:00', '15:30:00', 'lecture'),
(29, 'Thursday', '15:30:00', '17:00:00', 'lecture'),
(30, 'Thursday', '17:00:00', '18:30:00', 'lecture'),
(31, 'Thursday', '18:30:00', '20:00:00', 'lecture'),
(32, 'Thursday', '20:00:00', '21:30:00', 'lecture'),
(33, 'Friday', '09:00:00', '10:30:00', 'lecture'),
(34, 'Friday', '10:30:00', '12:00:00', 'lecture'),
(35, 'Friday', '12:00:00', '14:00:00', 'lecture'),
(36, 'Friday', '14:00:00', '15:30:00', 'lecture'),
(37, 'Friday', '15:30:00', '17:00:00', 'lecture'),
(38, 'Friday', '17:00:00', '18:30:00', 'lecture'),
(39, 'Friday', '18:30:00', '20:00:00', 'lecture'),
(40, 'Friday', '20:00:00', '21:30:00', 'lecture');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_login`
--
ALTER TABLE `admin_login`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `posted_by` (`posted_by`);

--
-- Indexes for table `assessments`
--
ALTER TABLE `assessments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `course_offering_id` (`course_offering_id`);

--
-- Indexes for table `batches`
--
ALTER TABLE `batches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_program` (`session`,`program_id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `conflict_requests`
--
ALTER TABLE `conflict_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `student_id` (`student_id`),
  ADD KEY `course_offering_id` (`course_offering_id`),
  ADD KEY `conflict_with` (`conflict_with`),
  ADD KEY `resolved_by` (`resolved_by`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `course_categories`
--
ALTER TABLE `course_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `program_id` (`program_id`);

--
-- Indexes for table `course_offerings`
--
ALTER TABLE `course_offerings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `course_section_semester` (`course_id`,`section_id`,`semester`),
  ADD KEY `section_id` (`section_id`),
  ADD KEY `faculty_id` (`faculty_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `faculty`
--
ALTER TABLE `faculty`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `final_grades`
--
ALTER TABLE `final_grades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_course_id` (`student_course_id`);

--
-- Indexes for table `prerequisites`
--
ALTER TABLE `prerequisites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `course_prerequisite` (`course_id`,`prerequisite_course_id`),
  ADD KEY `prerequisite_course_id` (`prerequisite_course_id`);

--
-- Indexes for table `programs`
--
ALTER TABLE `programs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `program_courses`
--
ALTER TABLE `program_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `program_course_semester` (`program_id`,`course_id`,`semester`),
  ADD KEY `course_id` (`course_id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `batch_semester_section` (`batch_id`,`semester`,`name`),
  ADD KEY `advisor_id` (`advisor_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `regno` (`regno`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `cnic` (`cnic`),
  ADD KEY `program_id` (`program_id`),
  ADD KEY `batch_id` (`batch_id`);

--
-- Indexes for table `student_courses`
--
ALTER TABLE `student_courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_course` (`student_id`,`course_offering_id`),
  ADD KEY `course_offering_id` (`course_offering_id`);

--
-- Indexes for table `student_login`
--
ALTER TABLE `student_login`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_id` (`student_id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indexes for table `student_results`
--
ALTER TABLE `student_results`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_assessment` (`student_course_id`,`assessment_id`),
  ADD KEY `assessment_id` (`assessment_id`);

--
-- Indexes for table `timetable`
--
ALTER TABLE `timetable`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `offering_time_slot` (`course_offering_id`,`time_slot_id`),
  ADD KEY `time_slot_id` (`time_slot_id`);

--
-- Indexes for table `time_slots`
--
ALTER TABLE `time_slots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `day_time_slot` (`day`,`start_time`,`end_time`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_login`
--
ALTER TABLE `admin_login`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `assessments`
--
ALTER TABLE `assessments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `batches`
--
ALTER TABLE `batches`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `conflict_requests`
--
ALTER TABLE `conflict_requests`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=128;

--
-- AUTO_INCREMENT for table `course_categories`
--
ALTER TABLE `course_categories`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `course_offerings`
--
ALTER TABLE `course_offerings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=80;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `faculty`
--
ALTER TABLE `faculty`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `final_grades`
--
ALTER TABLE `final_grades`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=62;

--
-- AUTO_INCREMENT for table `prerequisites`
--
ALTER TABLE `prerequisites`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `programs`
--
ALTER TABLE `programs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `program_courses`
--
ALTER TABLE `program_courses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=138;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `student_courses`
--
ALTER TABLE `student_courses`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT for table `student_login`
--
ALTER TABLE `student_login`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT for table `student_results`
--
ALTER TABLE `student_results`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `timetable`
--
ALTER TABLE `timetable`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `time_slots`
--
ALTER TABLE `time_slots`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_login`
--
ALTER TABLE `admin_login`
  ADD CONSTRAINT `admin_login_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`posted_by`) REFERENCES `admin_login` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `assessments`
--
ALTER TABLE `assessments`
  ADD CONSTRAINT `assessments_ibfk_1` FOREIGN KEY (`course_offering_id`) REFERENCES `course_offerings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `batches`
--
ALTER TABLE `batches`
  ADD CONSTRAINT `batches_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `conflict_requests`
--
ALTER TABLE `conflict_requests`
  ADD CONSTRAINT `conflict_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `conflict_requests_ibfk_2` FOREIGN KEY (`course_offering_id`) REFERENCES `course_offerings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `conflict_requests_ibfk_3` FOREIGN KEY (`conflict_with`) REFERENCES `course_offerings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `conflict_requests_ibfk_4` FOREIGN KEY (`resolved_by`) REFERENCES `admin_login` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `courses_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `course_categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `course_categories`
--
ALTER TABLE `course_categories`
  ADD CONSTRAINT `course_categories_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `course_offerings`
--
ALTER TABLE `course_offerings`
  ADD CONSTRAINT `course_offerings_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_offerings_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_offerings_ibfk_3` FOREIGN KEY (`faculty_id`) REFERENCES `faculty` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `faculty`
--
ALTER TABLE `faculty`
  ADD CONSTRAINT `faculty_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `final_grades`
--
ALTER TABLE `final_grades`
  ADD CONSTRAINT `final_grades_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_courses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `prerequisites`
--
ALTER TABLE `prerequisites`
  ADD CONSTRAINT `prerequisites_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prerequisites_ibfk_2` FOREIGN KEY (`prerequisite_course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `programs`
--
ALTER TABLE `programs`
  ADD CONSTRAINT `programs_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `program_courses`
--
ALTER TABLE `program_courses`
  ADD CONSTRAINT `program_courses_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `program_courses_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sections`
--
ALTER TABLE `sections`
  ADD CONSTRAINT `sections_ibfk_1` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sections_ibfk_2` FOREIGN KEY (`advisor_id`) REFERENCES `faculty` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `students_ibfk_2` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `student_courses`
--
ALTER TABLE `student_courses`
  ADD CONSTRAINT `student_courses_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_courses_ibfk_2` FOREIGN KEY (`course_offering_id`) REFERENCES `course_offerings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `student_login`
--
ALTER TABLE `student_login`
  ADD CONSTRAINT `student_login_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `student_results`
--
ALTER TABLE `student_results`
  ADD CONSTRAINT `student_results_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_courses` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_results_ibfk_2` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `timetable`
--
ALTER TABLE `timetable`
  ADD CONSTRAINT `timetable_ibfk_1` FOREIGN KEY (`course_offering_id`) REFERENCES `course_offerings` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `timetable_ibfk_2` FOREIGN KEY (`time_slot_id`) REFERENCES `time_slots` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
