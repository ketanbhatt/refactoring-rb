Issues with the code
1. Returns a string. Would like it to return a structured statment, that can be formatted separately to a suitable string. Makes testing easier + makes it easy to reuse the same raw data to generate different format, for eg, for emails OR Slack notifications?
2. Where we are adding extra credits for comedy, either there is a bug, or the comment has gone stale. Nevertheless, maybe we can do without the comment and make the code more readable
3. Overall, difficult to understand what is happening in the code. Can make it more readable very easily.
4. The method is doing too much, calculating volume credits and amount for each category. It would be better if I can hand over this responsibility to different classes that do the needful and my method just sums things up.
5. Also, because of #4, the code has become messy. It will become messier if the base price was different for different shows, which very well can happen.
6. Can further abstract things to have a fixed_amount, and an audience_threshold and then calculate an audience_overhead etc., but at the moment feels like an overkill. Too much cognitive load to read a simple method. So, I will just make a simple method for now.
7. Also looks like that the calculation is in cents and is being converted to dollars in the string. Code should make this explicit. Can name variable to be amount_in_cents or change the method to amount_in_cents or both.
8. Validations that audience can't be nil etc.

Martin
1. Extracted the switch case
2. Renamed variables for the extracted method
    1. By default, includes type in the name of the variable
3. Remove variable which can be calculated from one of the other param --> Replace temp with query. Why? No reason to create locally scoped variables that make refactoring difficult (extracting is difficult since you have to pass that variable around).
4. Moved calculation of "Total Volume Credits" and "Total Amount" to different functions altogether that loops over the performances again. Don't worry about looping again, performance hit is negligible.
    1. His first pass of refactoring resulted in a method where he is directly forming the message by calling methods directly. One method each for calculating amount and volume credtis for each performance, and one methods each for getting a total amount and credits that call the first two method.
    2. In his words: "The structure of the code is much better now. The top-level `statement` function is now just seven lines of code, and all it does is laying out the printing statements. All the calculation logic has been moved out to a handful of supporting functions. This makes it easier to understand each individual calculation as well as the overall flow of the report."
5. Then he extracted the calculation with the printing part of the code. Splitting the Phase. And using an intermediate data structure (hashmap/dictionary) to communicate. This is the same as what we did.
6. Then he is creating classes for different categories of plays. It is fun to see that he is also calling them "Calculators".
7. He kept the calculation of volume credits in just the base class and used it for both the classes. Yes that seems to be a better thing to do.


The process:
1. Decomposing the original function into a set of nested functions
2. Separate calculating and printing code
3. Introducing a polymorphic calculator for the calculation logic.


Changes that I made learning from him
1. Passing full performance and play to the calculator class. That's easier for the callers, they can pass what they have, and then the class can take out what it wants. I had gone for explicitly passing only what the calculators needed, and there is some argument for that too, example, the caller would know exactly what is needed, and the data they have (the dict) might not have these values but they will not know. Although, we can still put validations inside the class and check if what we want is passed in the dict so that we don't make this mistake, and still keep the call sites simpler. I like this.
2. Changed the Base class' volume_credits method to implement the common part. I had explicitly not done this when I wrote it because I thought it might be over abstraction. But after seeing how it looks, I find the changed version to be better, it keeps the code more readable. You can say, ok do what we are doing for every type + do this extra thing.
3. Renaming the classes, my names are too verbose and I didn't like them a lot too. I like his names better.
4. I think I went overboard with the definitions of the amount and volume credits methods. I opted for longer names, that did feel more readable, but I wasn't happy with them (I had this bad feeling, but I didn't do anything about it). Editing those methods to make them smaller like how Martin had in his code has made it more readable. I think the calculation was simple enough that just the maths of it would be enough to explain what's happening. I tried making it more readable by defining the variables and all, and that was counterproductive.
5. Inspired from this, made some minor changes to calculate_statement that I think makes it much better now.