
QR1. Which concept was hardest to understand: lists and loops, classes and methods, exception handling, 
or async/await? Walk through the specific moment of confusion and explain how you eventually understood it. 

The async/await concept was the hardest for me to understand at first. When I first implemented it, I 
expected the output to appear immediately like other functions. However, the result was printed after some
time because the function returned a Future and simulated a delay without blocking the rest of the program.
When I added await, I realized that it pauses the execution of that function until the Future is completed. 
This helped me understand how asynchronous operations work in Dart.

QR2. Look at your Task 1 solution. If you had to change your code to analyze a list of floating-point numbers 
(List<double>) instead of integers, how many places in your code would need to change? What does this tell 
you about the importance of thinking about data types during design? 

If I needed to change the program to use List<double> instead of List<int>, I would need to change many places 
in the code (around 9 places). These include variables such as max, min, and sum, the return type of calculateSum(), 
and the list declaration in main(). This shows that it is important to think carefully about data types before 
implementing the program, because changing types later can affect many parts of the code and make it more difficult 
to modify.

QR3. In Task 2, you simulated a network delay using Future.delayed(). Describe a real Flutter app feature where you 
would need to actually await a real asynchronous operation — not just a simulated delay. What would the Future 
resolve to, and what would happen to the UI while the user was waiting? 

For example loading images from a social media platform. A social media app needs to download profile pictures or 
posts from an online server after a user request. Requesting an image from the internet takes time, so the function 
that downloads the image would return a Future. In this case, the Future may resolve to something like Future<Image> 
depending on how the image is handled. While the user is waiting, the UI may display an image placeholder or loading 
spinner until the image data is received and the UI updates to display the actual image.


QR4. If a colleague asked you: 'Why not just use a single function that takes the operation name as a parameter, 
rather than writing separate add(), subtract(), multiply(), and divide() methods?' — what would you say? Are there
advantages to both approaches? 

Using separate functions for operations such as add, subtract, multiply, and divide makes the code easier to read,
understand, test, and debug. In some situations, using a single function that takes the operation name as a 
parameter can also be useful, especially when building a flexible system that selects operations dynamically. 
However, using separate methods improves readability, modularity, and maintainability, which are important 
principles in software development.
