-- phpMyAdmin SQL Dump
-- version 5.2.1deb1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 03, 2025 at 09:55 PM
-- Server version: 10.11.11-MariaDB-0+deb12u1
-- PHP Version: 8.2.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `workshopadmin`
--

-- --------------------------------------------------------

--
-- Table structure for table `carpentry`
--

CREATE TABLE `carpentry` (
  `carpentry_code` varchar(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `curriculum`
--

CREATE TABLE `curriculum` (
  `curriculum_code` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `emails`
--

CREATE TABLE `emails` (
  `person_id` int(10) UNSIGNED NOT NULL,
  `slug` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `flavour`
--

CREATE TABLE `flavour` (
  `flavour_id` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `helpers`
--

CREATE TABLE `helpers` (
  `person_id` int(11) UNSIGNED NOT NULL,
  `slug` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `instructors`
--

CREATE TABLE `instructors` (
  `person_id` int(10) UNSIGNED NOT NULL,
  `slug` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `people`
--

CREATE TABLE `people` (
  `person_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(5) DEFAULT NULL,
  `firstname` varchar(40) NOT NULL,
  `lastname` varchar(50) NOT NULL,
  `certified` tinyint(1) NOT NULL,
  `email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `room`
--

CREATE TABLE `room` (
  `room_id` varchar(10) NOT NULL,
  `description` varchar(60) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `what_three_words` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `workshops`
--

CREATE TABLE `workshops` (
  `slug` varchar(40) NOT NULL,
  `title` varchar(100) NOT NULL,
  `humandate` varchar(25) NOT NULL,
  `humantime` varchar(25) NOT NULL,
  `startdate` varchar(10) NOT NULL,
  `enddate` varchar(10) NOT NULL,
  `room_id` varchar(10) NOT NULL,
  `language` varchar(2) NOT NULL,
  `country` varchar(2) NOT NULL,
  `online` tinyint(1) NOT NULL,
  `pilot` tinyint(1) NOT NULL,
  `inc_lesson_site` varchar(100) NOT NULL,
  `pre_survey` varchar(100) NOT NULL,
  `post_survey` varchar(100) NOT NULL,
  `carpentry_code` varchar(9) NOT NULL,
  `curriculum_code` varchar(20) NOT NULL,
  `flavour_id` varchar(10) NOT NULL,
  `eventbrite` varchar(100) NOT NULL DEFAULT ' ',
  `schedule` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carpentry`
--
ALTER TABLE `carpentry`
  ADD UNIQUE KEY `carpentry_code` (`carpentry_code`);

--
-- Indexes for table `curriculum`
--
ALTER TABLE `curriculum`
  ADD UNIQUE KEY `curriculum_code` (`curriculum_code`);

--
-- Indexes for table `emails`
--
ALTER TABLE `emails`
  ADD UNIQUE KEY `emails` (`person_id`,`slug`) USING BTREE,
  ADD KEY `workshop` (`slug`);

--
-- Indexes for table `flavour`
--
ALTER TABLE `flavour`
  ADD UNIQUE KEY `flavour_id` (`flavour_id`);

--
-- Indexes for table `helpers`
--
ALTER TABLE `helpers`
  ADD UNIQUE KEY `helpers` (`person_id`,`slug`);

--
-- Indexes for table `instructors`
--
ALTER TABLE `instructors`
  ADD UNIQUE KEY `instructors` (`person_id`,`slug`) USING BTREE,
  ADD KEY `workshopinstructor` (`slug`);

--
INT `slug` FOREIGN KEY (`slug`) REFERENCES `workshops` (`slug`);

--
-- Constraints for table `instructors`
--
ALTER TABLE `instructors`
  ADD CONSTRAINT `instructor` FOREIGN KEY (`person_id`) REFERENCES `people` (`person_id`),
  ADD CONSTRAINT `workshopinstructor` FOREIGN KEY (`slug`) REFERENCES `workshops` (`slug`);

--
-- Constraints for table `workshops`
--
ALTER TABLE `workshops`
  ADD CONSTRAINT `carpentry` FOREIGN KEY (`carpentry_code`) REFERENCES `carpentry` (`carpentry_code`),
  ADD CONSTRAINT `curriculum` FOREIGN KEY (`curriculum_code`) REFERENCES `curriculum` (`curriculum_code`),
  ADD CONSTRAINT `flavour` FOREIGN KEY (`flavour_id`) REFERENCES `flavour` (`flavour_id`),
  ADD CONSTRAINT `room` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
