-- Database backup generated on 2025-01-25T12:26:00Z
-- Project: ovkbimpzvewdryjzspen
-- Backup type: complete

-- Disable foreign key checks during restore
SET session_replication_role = replica;

-- Insert profiles data
INSERT INTO public.profiles (id, name, email, role, membership_tier, priority_position, balance, monthly_fee_status, created_at, updated_at) VALUES
('70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', 'thiago araujo', 'chasp.habi@gmail.com', 'client', 'basic', 1, 11783.00, 'paid', '2025-06-17T15:32:34.897046+00:00', '2025-06-17T15:32:34.897046+00:00'),
('795c4283-d6c3-4cdd-bcab-08dabda64be6', 'joao aresta', 'agendoai@gmail.com', 'client', 'basic', 2, 39290.00, 'paid', '2025-06-18T12:52:12.533536+00:00', '2025-06-18T12:52:12.533536+00:00');

-- Insert aircraft data
INSERT INTO public.aircraft (id, name, model, registration, hourly_rate, max_passengers, status, maintenance_status, seat_configuration, created_at, updated_at) VALUES
('ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'Citation CJ3+', 'Cessna Citation CJ3+', 'PR-ECA', 4200.00, 6, 'available', 'operational', '{"layout": "2-2", "total_seats": 6, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00'),
('27ff71e4-22f4-438e-88dd-34e4522fe475', 'Phenom 300', 'Embraer Phenom 300', 'PR-ECB', 4200.00, 8, 'available', 'operational', '{"layout": "2-2", "total_seats": 8, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}, {"number": 7, "position": "C", "row": 2, "type": "standard"}, {"number": 8, "position": "D", "row": 2, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00'),
('8ef96852-8c93-42e6-9cc7-8ef700a9de63', 'King Air 350', 'Beechcraft King Air 350', 'PR-ECC', 4200.00, 9, 'available', 'operational', '{"layout": "2-2", "total_seats": 9, "seats": [{"number": 1, "position": "A", "row": 1, "type": "standard"}, {"number": 2, "position": "B", "row": 1, "type": "standard"}, {"number": 3, "position": "C", "row": 1, "type": "standard"}, {"number": 4, "position": "D", "row": 1, "type": "standard"}, {"number": 5, "position": "A", "row": 2, "type": "standard"}, {"number": 6, "position": "B", "row": 2, "type": "standard"}, {"number": 7, "position": "C", "row": 2, "type": "standard"}, {"number": 8, "position": "D", "row": 2, "type": "standard"}, {"number": 9, "position": "A", "row": 3, "type": "standard"}]}', '2025-06-16T17:07:04.534468+00:00', '2025-06-16T17:07:04.534468+00:00');

-- Insert bookings data
INSERT INTO public.bookings (id, user_id, aircraft_id, origin, destination, departure_date, departure_time, return_date, return_time, passengers, flight_hours, airport_fees, overnight_stays, overnight_fee, total_cost, status, priority_expires_at, maintenance_buffer_hours, stops, blocked_until, created_at, updated_at) VALUES
('479106e6-d767-4ee3-895c-b19313df0823', '70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', '27ff71e4-22f4-438e-88dd-34e4522fe475', 'Aracatuba', 'Sao paulo', '2025-06-19', '09:38:00', '2025-06-20', '10:39:00', 4, 1.5, 417.00, 1, 1500.00, 8217.00, 'pending', '2025-06-19T12:40:14.701602+00:00', 3, NULL, NULL, '2025-06-18T12:40:14.701602+00:00', '2025-06-18T12:40:14.701602+00:00'),
('290ba8c1-a001-40fb-a34d-73c4b0e6c552', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '27ff71e4-22f4-438e-88dd-34e4522fe475', 'Aracatuba', 'Sao paulo', '2025-06-20', '12:00:00', '2025-06-21', '10:00:00', 2, 1.5, 417.00, 1, 1500.00, 8217.00, 'pending', '2025-06-19T13:01:09.200276+00:00', 3, NULL, NULL, '2025-06-18T13:01:09.200276+00:00', '2025-06-18T13:01:09.200276+00:00'),
('4395e8b6-e162-4c35-8bc0-097eb50a1d81', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '8ef96852-8c93-42e6-9cc7-8ef700a9de63', 'Aracatuba', 'Sao paulo', '2025-06-19', '15:40:00', '2025-06-20', '15:40:00', 2, 2.6, 417.00, 0, 0.00, 11337.00, 'pending', '2025-06-19T18:41:27.413736+00:00', 3, 'mato grosso', NULL, '2025-06-18T18:41:27.413736+00:00', '2025-06-18T18:41:27.413736+00:00'),
('d76c140a-3420-4003-a68b-340db4034233', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'GRU', 'sao paulo', '2024-07-28', '10:00:00', '2024-07-23', '18:00:00', 2, 2.5, 0.00, 0, 0.00, 10710.00, 'confirmed', NULL, 3, NULL, '2024-07-28T15:30:00+00:00', '2025-07-02T12:06:39.876874+00:00', '2025-07-02T12:06:39.876874+00:00');

-- Insert pre_reservations data
INSERT INTO public.pre_reservations (id, user_id, aircraft_id, origin, destination, departure_date, departure_time, return_date, return_time, passengers, flight_hours, total_cost, priority_position, expires_at, overnight_stays, overnight_fee, payment_method, status, created_at, updated_at) VALUES
('dfa5511b-a687-4fb0-9493-2da065c2d552', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'ddec6094-2eb8-49cb-97c3-657fcb5357e4', 'GRU', 'sao paulo', '2024-07-28', '10:00:00', '2024-07-23', '18:00:00', 2, 2.5, 10500.00, 2, '2025-07-03T00:06:29.176003+00:00', 0, 0, 'card', 'confirmed', '2025-07-02T12:06:29.176003+00:00', '2025-07-02T12:06:29.176003+00:00');

-- Insert transactions data
INSERT INTO public.transactions (id, user_id, booking_id, amount, type, description, created_at) VALUES
('70d46731-7e31-4d5a-ad4c-ee3a2426c060', '70f83e50-5aa5-4a8a-a7e1-c1e6f5089a57', '479106e6-d767-4ee3-895c-b19313df0823', 8217.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T12:40:14.701602+00:00'),
('585fc423-86c0-4e6d-93bc-d8ce241ce440', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '290ba8c1-a001-40fb-a34d-73c4b0e6c552', 8217.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T13:01:09.200276+00:00'),
('d4610dec-c697-46a5-8851-fbe352aded5c', '795c4283-d6c3-4cdd-bcab-08dabda64be6', '4395e8b6-e162-4c35-8bc0-097eb50a1d81', 11337.00, 'debit', 'Reserva Aracatuba → Sao paulo', '2025-06-18T18:41:27.413736+00:00'),
('fa2a201c-f9a1-470a-888c-6283abd52ceb', '795c4283-d6c3-4cdd-bcab-08dabda64be6', 'd76c140a-3420-4003-a68b-340db4034233', 10710.00, 'debit', 'Reserva GRU → sao paulo', '2025-07-02T12:06:39.876874+00:00');

-- Insert priority_slots data
INSERT INTO public.priority_slots (id, slot_number, is_available, created_at, updated_at) VALUES
('f07c4673-00f5-440e-b5ae-0172bf07028d', 1, true, '2025-06-18T15:27:53.730451+00:00', '2025-06-18T15:27:53.730451+00:00'),
('cfd1ab74-b035-4890-bd6b-7075b824457e', 2, true, '2025-06-18T15:27:53.730451+00:00', '2025-06-18T15:27:53.730451+00:00');

-- Re-enable foreign key checks
SET session_replication_role = DEFAULT;

-- Backup Summary:
-- Total users: 2
-- Total aircraft: 3
-- Total bookings: 4
-- Total pre_reservations: 1
-- Total transactions: 4
-- Priority slots available: 100
-- Total user balance: R$ 51,073.00
-- Generated at: 2025-01-25T12:26:00Z