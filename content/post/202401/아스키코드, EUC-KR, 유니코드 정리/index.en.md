+++
author = "penguinit"
Title = "ASCII Code, EUC-KR, Unicode Organization"
date = "2024-01-22"
Description = "When I'm programming, I get into trouble with encoding. These days, most of the encoding is done mechanically with UTF-8, but in the past, there were some mistakes that caused problems when Hangul was entered by the wrong encoding, and if you develop it in practice..."
tags = [
"ascii", "euc-kr", "unicode"
]

categories = [
"encoding",
]
+++

## Overview

There are some problems with encoding while programming. Most of the encoding is done mechanically with 'UTF-8' these days, but in the past, there were mistakes that caused problems when Hangul was entered by incorrect encoding, and there were experiences that occurred because they did not understand encoding well when developing it in practice. Through this article, I would like to summarize the concept of encoding, the history of ASCII, and EUC-KR Unicode.

## What is encoding

Encoding refers to the conversion of data into a particular format or format. The conversion here refers to the conversion into a form that the computer can understand and process.

The term encoding is used in various ways and refers to the conversion of certain data, such as strings, images, and videos, into forms that the computer can understand. On the other hand, the process of converting data into original data is called **decoding**.

## ASCII Code

The ASCII is the first string encoding to represent a character using seven bits (bit is a binary number, 0 or 1).

Seven bits can represent up to 128 different characters (2^7 = 128). For example, 65 times represents an uppercase 'A', which is described as **01000001**. Although the ASCII is simple and simple, it had its limitations in expressing a variety of languages and symbols beyond English and basic control characters.

![Untitled](images/Untitled.png)

## EUC-KR

After the ASCII, many countries began to develop their own encoding systems. One of the biggest reasons is the limitation of the existing ASCII. Even if the same alphabet was used, certain cultures had various restrictions. For example, French, German, and Spanish use accented characters and had a completely different writing system outside the English-speaking world.

The **ISO-8859** series of European languages with the concept of extending the existing ASCII has begun to emerge, and unique encoding systems have begun to be created to express the unique writing system of each language, including China's **GB2312** Japan's **Shift_JIS** Korea's **EUC-KR**.

### EUC-KR Structure

EUC-KR is an 8-bit (1-byte) based encoding system that uses 2 bytes (16 bits) to represent a single syllable. Two bytes (16 bits) can represent 2^16 = 65,536 different states. Traditionally, it was compatible with ASCII character sets, allowing it to handle documents with mixed alphabets and Korean characters. However, it also had its limitations: EUC-KR encoding was able to represent 8,000 characters, including a total of 2,350 Korean syllables and Chinese characters.

Hangeul can theoretically create approximately 11,172 syllable combinations (including 19 primitives x 21 neutrals x 28 apoptosis if there is no apoptosis). However, ECU-KR did not support all combinations, so it is an encoding scheme that clearly had its limitations.

### Actual performance of EUC-KR encoding

I want to see how the word penguin is expressed in EUC-KR.

```bash
echo "펭귄" | iconv -t euc-kr | hexdump -C

00000000 c6 eb b1 cf 0a |.....|
00000005
```

- **`c6eb`**: EUC-KR encoding corresponding to the letter "Peng".
- **`b1 cf`**: EUC-KR encoding corresponding to the letter "guin".
- **`0a`**: This represents a line feed (line feed), a control character often used in text output.

If you check the EUC-KR table, it's easier to check. [EUC-KR Text Table] (https://www.fileformat.info/info/charset/EUC-KR/grid.htm)

### full-form encoding

EUC-KR follows a complete type system. Each letter (syllable) in Hangul is already encoded in a combined form, and the user does not separately combine each initial, neutral, and final consonant.

## Unicode

Unicode is a string system that incorporates all of these problems. Unicode offers various encoding formats (e.g., UTF-8, UTF-16, and UTF-32), and each format has a different way of storing characters.

Sometimes some people think of Unicode as one of the ways in which encode it, but to be precise, Unicode is a standard for defining character sets and identifying characters uniquely. The definition and addition of Unicode characters is managed by the Unicode Consortium [https://home.unicode.org/) ], and new characters or emojis are defined and added by this consortium.

Currently, Unicode can process up to 4 bytes and theoretically represent 2^32(4,294,967,296) characters

The reason why there are so many encoding schemes in Unicode is that it is inefficient to use 4 bytes to store and represent a single character, providing several ways to process it in an efficient way. The most common use is UTF-8.

![Untitled](images/Untitled%201.png)
### Unicode Status

So far, the number of characters defined in the Unicode standard continues to grow, with new characters or emojis added every year. As of Jan. 22, 2024, [https://www.unicode.org/versions/Unicode15.1.0/) ] has a total of 149,813 characters up to date. This number is added whenever the version is updated, and you can check the release notes for more information.

### Unicode Configuration

1. Code Point:
- In Unicode, each character is identified by a unique code point (numbers).
- For example, the code point for the Latin alphabet "A" is U+0041, and the code point for the Korean alphabet "A" is U+AC00.
- Code points are expressed in hexadecimal and begin with "U+".
2. Planes (Planes)
- In Unicode, characters consist of large groups called planes. Each plane has a unique range of code points.
3. Character blocks (Blocks):
- Character categories consist of larger character blocks. Blocks group associated character sets, such as Latin-1 supplements, Korean syllables, and emoji blocks.

![Basic multilingual plane, BMP](images/Untitled%202.png)

> Basic multilingual plane, BMP

If you want to find a Unicode for the complete syllable that corresponds to the word penguin, you can find it below.

[Reference Site] (https://www.compart.com/en/unicode/)

- 펭 (U+D3AD) : [https://www.compart.com/en/unicode/U+D3AD](https://www.compart.com/en/unicode/U+D3AD)
- 귄 (U+ADC4) : [https://www.compart.com/en/unicode/U+ADC4](https://www.compart.com/en/unicode/U+ADC4)

Unicode can be up to four bytes and is expressed in hexadecimal. Here, U+D3AD is called **code point**. If you follow the link, you'll find an entry called 'Plane,' which belongs to the plane called [https://www.compart.com/en/unicode/plane/U+0000) (BMP)] and corresponds to the character block of [Hangul Silables, U+AC00 - U+D7AF] (https://www.compart.com/en/unicode/block/U+AC00) ).

## conclusion

I summarized the trend and concept of string processing from ASCII, EUC-KR, Unicode, and UTF-8. What I wanted to cover more was the UTF-8 encoding part, which I didn't mention in detail above, but when it was developed, Korean is processed as 3 bytes and English is processed as 1 byte, all of which are caused by UTF-8. If we have time, we will go into more detail about UTF-8 encoding.