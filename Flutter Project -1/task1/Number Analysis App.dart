// Task 1: Number Analysis App
// Name: Tamrat Arage

// Returns the largest value in the list using a manual loop
int findMax(List<int> numbers) {
  int max = numbers[0]; // start with first element

  for (int num in numbers) {
    if (num > max) {
      max = num;
    }
  }

  return max;
}

// Returns the smallest value in the list using a manual loop
int findMin(List<int> numbers) {
  int min = numbers[0];

  for (int num in numbers) {
    if (num < min) {
      min = num;
    }
  }

  return min;
}

// Calculates the sum of all numbers using accumulator pattern
int calculateSum(List<int> numbers) {
  int sum = 0;

  for (int num in numbers) {
    sum += num;
  }

  return sum;
}

// Calculates average by calling calculateSum()
double calculateAverage(List<int> numbers) {
  int sum = calculateSum(numbers);
  return sum / numbers.length;
}

void main() {
  final numbers = <int>[34, -7, 89, 12, -45, 67, 3, 100, -2, 55];

  final maxValue = findMax(numbers);
  final minValue = findMin(numbers);
  final sum = calculateSum(numbers);
  final average = calculateAverage(numbers);

  print('Number Analysis Results');
  print('========================');
  print('Numbers: $numbers');
  print('Maximum value : $maxValue');
  print('Minimum value : $minValue');
  print('Sum : $sum');
  print('Average : $average');
}
