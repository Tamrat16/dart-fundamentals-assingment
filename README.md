# Dart Fundamentals — Programming Assignment 1

**Name:** Tamrat Arage
**Course:** Software Engineering — Addis Ababa University
**Assignment:** Programming Assignment 1: Dart Fundamentals

---

## Overview

This repository contains two Dart programs built as part of Programming Assignment 1. The assignment covers core Dart concepts including typed lists, functions, object-oriented programming, exception handling, and asynchronous programming.

---

## Repository Structure

```
dart-fundamentals-assignment/
├── task1/
│   └── number_analysis.dart
├── task2/
│   └── calculator_app.dart
├── reflection.md
└── README.md
```

---

## Task 1 — Number Analysis App

**File:** `task1/number_analysis.dart`

This program performs statistical analysis on a predefined list of integers. It implements four functions from scratch — without relying on built-in Dart collection methods — to demonstrate manual control flow and the accumulator pattern.

**Functions implemented:**
- `findMax(List<int> numbers)` — returns the largest value using a loop
- `findMin(List<int> numbers)` — returns the smallest value using a loop
- `calculateSum(List<int> numbers)` — sums all values using an accumulator
- `calculateAverage(List<int> numbers)` — returns the average as a `double`, internally calling `calculateSum()`

**Sample output** (with list `[34, -7, 89, 12, -45, 67, 3, 100, -2, 55]`):
```
Number Analysis Results
========================
Numbers: [34, -7, 89, 12, -45, 67, 3, 100, -2, 55]
Maximum value : 100
Minimum value : -45
Sum : 306
Average : 30.6
```

---

## Task 2 — Async Calculator App

**File:** `task2/calculator_app.dart`

This program implements a `Calculator` class that encapsulates four arithmetic operations and demonstrates Dart's asynchronous programming model using `Future`, `async`, and `await`.

**Key features:**
- `add()`, `subtract()`, `multiply()`, `divide()` — synchronous arithmetic methods
- `divide()` throws an `ArgumentError` on division by zero
- `computeAsync()` — asynchronous method that simulates a 1.5-second processing delay using `Future.delayed()`
- `displayResult()` — async method with `try-catch` for graceful error handling

**Sample output:**
```
--- MyCalculator ---
add(10.0, 4.0) = 14.0
subtract(10.0, 4.0) = 6.0
multiply(10.0, 4.0) = 40.0
divide(10.0, 4.0) = 2.5
divide(15.0, 3.0) = 5.0
Error: ArgumentError: Cannot divide by zero.
All calculations complete.
```
*(Each result is printed after a 1.5-second pause.)*

---

## How to Run

All code was written and tested using [DartPad](https://dartpad.dev) — no local installation required.

To run locally with the Dart SDK installed:
```bash
dart task1/number_analysis.dart
dart task2/calculator_app.dart
```

---

## Tools Used

- [DartPad](https://dartpad.dev) — browser-based Dart environment
- Git & GitHub — version control and submission
