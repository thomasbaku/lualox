# Lua Lox Implementation by Utsav Basu, Rollins Baird, Thomas Hampton, and Connor Smith

An implementation of Lox in Lua for CS 403 with Professor Yessick.

## Why Lua?

Lua is a lightweight, high-level language designed for imbedded systems. It is dynamically typed, garbage colected language with only 22 reserved words. It has only one data structure, the table, which is quite flexable and does not use 0-based indexeing, indicies start at 1. It is easy to imbed Lua code within a C program and Lua is generally much faster than similar languages. Overall, Lua is a very straitforeward language that produces readable code. I could definitely see myself using Lua in the future for standalone programs or within a C program.

## Implemented Features

- and
- or
- true
- false
- nil
- if
- else
- for
- while
- fun
- print
- return
- var
- \+
- \-
- \*
- /
- =
- ==
- <
- <=
- \>
- \>=

## Tests

- featuretest.lox: does one by one checks of each implemented feature\

![Output for featuretest.lox](tests\output\featuretests.png "All feature tests pass")

- fib.lox: prints the first 92 fibonacci numbers (screenshot only shows the first few)

![Output for fib.lox](tests\output\fibnumbers.png "The first few of 92 fibonacci numbers")

- gradebook.lox: calculates final grade for CS 403

![Output for gradebook.lox](tests\output\finalgrade.png "Print out of calculated grade")

- mod.lox: implements mod function and uses it to calculate change in coins for a given dollar amount

![Output for mod.lox](tests\output\change.png "Change for $3.99 displayed")

## Run Instructions

To use repl: ```lua54 loxrepl.lua```

To run file: ```lua54 loxrepl.lua [filepath]```
