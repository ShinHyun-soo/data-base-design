-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- 생성 시간: 24-11-26 05:34
-- 서버 버전: 10.4.32-MariaDB
-- PHP 버전: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 데이터베이스: `test`
--

-- --------------------------------------------------------

--
-- 테이블 구조 `delivery_company`
--

CREATE TABLE `delivery_company` (
  `company_id` int(11) NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `company_address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `delivery_company`
--

INSERT INTO `delivery_company` (`company_id`, `company_name`, `company_address`) VALUES
(1, 'A company', 'Seoul'),
(2, 'B company', 'Gwangju');

-- --------------------------------------------------------

--
-- 테이블 구조 `delivery_issue_management`
--

CREATE TABLE `delivery_issue_management` (
  `issue_id` int(11) NOT NULL,
  `issue_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `delivery_issue_management`
--

INSERT INTO `delivery_issue_management` (`issue_id`, `issue_name`) VALUES
(1, '배송 오류'),
(2, '배달 지연'),
(3, '물품 오류');

-- --------------------------------------------------------

--
-- 테이블 구조 `delivery_personnel`
--

CREATE TABLE `delivery_personnel` (
  `personnel_id` int(11) NOT NULL,
  `company_id` int(11) NOT NULL,
  `personnel_name` varchar(255) NOT NULL,
  `delivery_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `delivery_personnel`
--

INSERT INTO `delivery_personnel` (`personnel_id`, `company_id`, `personnel_name`, `delivery_id`) VALUES
(1, 1, 'John Doe', 1),
(2, 1, 'Jane Smith', 2),
(3, 1, 'Luna', 3),
(4, 1, 'Himel', 4),
(5, 1, 'Kuki', 5),
(6, 1, 'Blue', 6),
(7, 1, 'Hat', 7),
(8, 1, 'Horn', 8),
(9, 1, 'Karen', 9),
(10, 1, 'Smith', 10),
(11, 1, 'June', 11),
(12, 1, 'Karel', 12),
(13, 1, 'Ben', 13),
(14, 1, 'Billy', 14),
(15, 1, 'Sent', 15),
(16, 1, 'Tom', 16),
(17, 2, 'John Till', 1),
(18, 2, 'Jane Tim', 2),
(19, 2, 'Trin', 3),
(20, 2, 'Frieren', 4),
(21, 2, 'Lone', 5),
(22, 2, 'Red', 6),
(23, 2, 'Toe', 7),
(24, 2, 'Kun', 8),
(25, 2, 'Haren', 9),
(26, 2, 'Spoon', 10),
(27, 2, 'July', 11),
(28, 2, 'Kim', 12),
(29, 2, 'Bell', 13),
(30, 2, 'Till', 14),
(31, 2, 'Solt', 15),
(32, 2, 'Tim', 16);

-- --------------------------------------------------------

--
-- 테이블 구조 `employee`
--

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `factory`
--

CREATE TABLE `factory` (
  `factory_id` int(11) NOT NULL,
  `factory_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `factory`
--

INSERT INTO `factory` (`factory_id`, `factory_name`) VALUES
(1, 'A factory'),
(2, 'B factory');

-- --------------------------------------------------------

--
-- 테이블 구조 `inquiry`
--

CREATE TABLE `inquiry` (
  `inquiry_id` int(11) NOT NULL,
  `inquiry_comment` varchar(255) NOT NULL,
  `problem_state` tinyint(1) NOT NULL,
  `user_id` int(11) NOT NULL,
  `parcel_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `make_order`
--

CREATE TABLE `make_order` (
  `order_id` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `availability_date` date NOT NULL,
  `user_id` int(11) NOT NULL,
  `receiver_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `parcel`
--

CREATE TABLE `parcel` (
  `parcel_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `delivery_id` int(11) NOT NULL,
  `current_state` tinyint(1) NOT NULL,
  `personnel_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `product`
--

CREATE TABLE `product` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `factory_id` int(11) NOT NULL,
  `warehouse_id` int(11) NOT NULL,
  `stock` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `product`
--

INSERT INTO `product` (`product_id`, `product_name`, `factory_id`, `warehouse_id`, `stock`) VALUES
(1001, 'mouse', 1, 1, 0),
(1002, 'keyboard', 1, 1, 0),
(2001, 'shirt', 2, 2, 10),
(2002, 'skirt', 2, 2, 10);

-- --------------------------------------------------------

--
-- 테이블 구조 `receiver`
--

CREATE TABLE `receiver` (
  `receiver_id` int(11) NOT NULL,
  `receiver_name` varchar(255) NOT NULL,
  `receiver_phone` varchar(255) NOT NULL,
  `receiver_address` varchar(255) NOT NULL,
  `receiver_zip_code` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `report`
--

CREATE TABLE `report` (
  `report_id` int(11) NOT NULL,
  `report_comment` varchar(255) NOT NULL,
  `issue_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `inquiry_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `shipment_state`
--

CREATE TABLE `shipment_state` (
  `current_state` tinyint(1) NOT NULL,
  `state_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `shipment_state`
--

INSERT INTO `shipment_state` (`current_state`, `state_name`) VALUES
(0, 'In delivery'),
(1, 'Delivery completed');

-- --------------------------------------------------------

--
-- 테이블 구조 `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `user_email` varchar(255) NOT NULL,
  `user_password` text NOT NULL,
  `user_phone` varchar(255) NOT NULL,
  `user_address` varchar(255) NOT NULL,
  `user_type` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- 테이블 구조 `warehouse`
--

CREATE TABLE `warehouse` (
  `warehouse_id` int(11) NOT NULL,
  `warehouse_name` varchar(255) NOT NULL,
  `warehouse_address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- 테이블의 덤프 데이터 `warehouse`
--

INSERT INTO `warehouse` (`warehouse_id`, `warehouse_name`, `warehouse_address`) VALUES
(1, 'A warehouse', 'Seoul'),
(2, 'B warehouse', 'Gwangju');

-- --------------------------------------------------------

--
-- 테이블 구조 `zone`
--

CREATE TABLE `zone` (
  `delivery_id` int(11) NOT NULL,
  `delivery_zone` varchar(255) NOT NULL,
  `zip_code_start` varchar(255) NOT NULL,
  `zip_code_end` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- 테이블의 덤프 데이터 `zone`
--

INSERT INTO `zone` (`delivery_id`, `delivery_zone`, `zip_code_start`, `zip_code_end`) VALUES
(1, 'Seoul', '010', '088'),
(2, 'Gyeonggi-do', '100', '186'),
(3, 'Incheon', '210', '231'),
(4, 'Gangwon', '240', '263'),
(5, 'Chungcheongbuk-do', '270', '291'),
(6, 'Sejong', '300', '301'),
(7, 'Chungcheongnam-do', '310', '336'),
(8, 'Daejeon', '340', '354'),
(9, 'Gyeongsangbuk-do', '360', '402'),
(10, 'Daegu', '410', '431'),
(11, 'Ulsan', '440', '450'),
(12, 'Busan', '460', '495'),
(13, 'Gyeongsangnam-do', '500', '533'),
(14, 'Jeonbuk', '540', '564'),
(15, 'Jeollanam-do', '570', '598'),
(16, 'Gwangju', '610', '624'),
(17, 'Jeju', '630', '636');

--
-- 덤프된 테이블의 인덱스
--

--
-- 테이블의 인덱스 `delivery_company`
--
ALTER TABLE `delivery_company`
  ADD PRIMARY KEY (`company_id`);

--
-- 테이블의 인덱스 `delivery_issue_management`
--
ALTER TABLE `delivery_issue_management`
  ADD PRIMARY KEY (`issue_id`);

--
-- 테이블의 인덱스 `delivery_personnel`
--
ALTER TABLE `delivery_personnel`
  ADD PRIMARY KEY (`personnel_id`),
  ADD KEY `company_id` (`company_id`),
  ADD KEY `delivery_id` (`delivery_id`);

--
-- 테이블의 인덱스 `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`),
  ADD KEY `user_id` (`user_id`);

--
-- 테이블의 인덱스 `factory`
--
ALTER TABLE `factory`
  ADD PRIMARY KEY (`factory_id`);

--
-- 테이블의 인덱스 `inquiry`
--
ALTER TABLE `inquiry`
  ADD PRIMARY KEY (`inquiry_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `parcel_id` (`parcel_id`);

--
-- 테이블의 인덱스 `make_order`
--
ALTER TABLE `make_order`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `make_order_ibfk_2` (`receiver_id`),
  ADD KEY `make_order_ibfk_3` (`product_id`);

--
-- 테이블의 인덱스 `parcel`
--
ALTER TABLE `parcel`
  ADD PRIMARY KEY (`parcel_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `current_state` (`current_state`),
  ADD KEY `delivery_id` (`delivery_id`);

--
-- 테이블의 인덱스 `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `product_ibfk_1` (`factory_id`),
  ADD KEY `warehouse_id` (`warehouse_id`);

--
-- 테이블의 인덱스 `receiver`
--
ALTER TABLE `receiver`
  ADD PRIMARY KEY (`receiver_id`);

--
-- 테이블의 인덱스 `report`
--
ALTER TABLE `report`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `issue_id` (`issue_id`),
  ADD KEY `employee_id` (`employee_id`),
  ADD KEY `inquiry_id` (`inquiry_id`);

--
-- 테이블의 인덱스 `shipment_state`
--
ALTER TABLE `shipment_state`
  ADD PRIMARY KEY (`current_state`);

--
-- 테이블의 인덱스 `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`);

--
-- 테이블의 인덱스 `warehouse`
--
ALTER TABLE `warehouse`
  ADD PRIMARY KEY (`warehouse_id`);

--
-- 테이블의 인덱스 `zone`
--
ALTER TABLE `zone`
  ADD PRIMARY KEY (`delivery_id`);

--
-- 덤프된 테이블의 AUTO_INCREMENT
--

--
-- 테이블의 AUTO_INCREMENT `delivery_company`
--
ALTER TABLE `delivery_company`
  MODIFY `company_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 테이블의 AUTO_INCREMENT `delivery_issue_management`
--
ALTER TABLE `delivery_issue_management`
  MODIFY `issue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 테이블의 AUTO_INCREMENT `delivery_personnel`
--
ALTER TABLE `delivery_personnel`
  MODIFY `personnel_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- 테이블의 AUTO_INCREMENT `employee`
--
ALTER TABLE `employee`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- 테이블의 AUTO_INCREMENT `factory`
--
ALTER TABLE `factory`
  MODIFY `factory_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- 테이블의 AUTO_INCREMENT `inquiry`
--
ALTER TABLE `inquiry`
  MODIFY `inquiry_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- 테이블의 AUTO_INCREMENT `make_order`
--
ALTER TABLE `make_order`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=281;

--
-- 테이블의 AUTO_INCREMENT `parcel`
--
ALTER TABLE `parcel`
  MODIFY `parcel_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- 테이블의 AUTO_INCREMENT `product`
--
ALTER TABLE `product`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3003;

--
-- 테이블의 AUTO_INCREMENT `receiver`
--
ALTER TABLE `receiver`
  MODIFY `receiver_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=307;

--
-- 테이블의 AUTO_INCREMENT `report`
--
ALTER TABLE `report`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- 테이블의 AUTO_INCREMENT `shipment_state`
--
ALTER TABLE `shipment_state`
  MODIFY `current_state` tinyint(1) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- 테이블의 AUTO_INCREMENT `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- 테이블의 AUTO_INCREMENT `warehouse`
--
ALTER TABLE `warehouse`
  MODIFY `warehouse_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- 테이블의 AUTO_INCREMENT `zone`
--
ALTER TABLE `zone`
  MODIFY `delivery_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- 덤프된 테이블의 제약사항
--

--
-- 테이블의 제약사항 `delivery_personnel`
--
ALTER TABLE `delivery_personnel`
  ADD CONSTRAINT `delivery_personnel_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `delivery_company` (`company_id`),
  ADD CONSTRAINT `delivery_personnel_ibfk_2` FOREIGN KEY (`delivery_id`) REFERENCES `zone` (`delivery_id`);

--
-- 테이블의 제약사항 `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`);

--
-- 테이블의 제약사항 `inquiry`
--
ALTER TABLE `inquiry`
  ADD CONSTRAINT `inquiry_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `inquiry_ibfk_3` FOREIGN KEY (`parcel_id`) REFERENCES `parcel` (`parcel_id`);

--
-- 테이블의 제약사항 `make_order`
--
ALTER TABLE `make_order`
  ADD CONSTRAINT `make_order_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`),
  ADD CONSTRAINT `make_order_ibfk_2` FOREIGN KEY (`receiver_id`) REFERENCES `receiver` (`receiver_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `make_order_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`) ON DELETE CASCADE;

--
-- 테이블의 제약사항 `parcel`
--
ALTER TABLE `parcel`
  ADD CONSTRAINT `parcel_ibfk_3` FOREIGN KEY (`order_id`) REFERENCES `make_order` (`order_id`),
  ADD CONSTRAINT `parcel_ibfk_4` FOREIGN KEY (`delivery_id`) REFERENCES `zone` (`delivery_id`),
  ADD CONSTRAINT `parcel_ibfk_5` FOREIGN KEY (`current_state`) REFERENCES `shipment_state` (`current_state`),
  ADD CONSTRAINT `parcel_ibfk_6` FOREIGN KEY (`delivery_id`) REFERENCES `delivery_personnel` (`personnel_id`);

--
-- 테이블의 제약사항 `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`factory_id`) REFERENCES `factory` (`factory_id`),
  ADD CONSTRAINT `product_ibfk_2` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`warehouse_id`);

--
-- 테이블의 제약사항 `report`
--
ALTER TABLE `report`
  ADD CONSTRAINT `report_ibfk_1` FOREIGN KEY (`issue_id`) REFERENCES `delivery_issue_management` (`issue_id`),
  ADD CONSTRAINT `report_ibfk_2` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`),
  ADD CONSTRAINT `report_ibfk_3` FOREIGN KEY (`inquiry_id`) REFERENCES `inquiry` (`inquiry_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
