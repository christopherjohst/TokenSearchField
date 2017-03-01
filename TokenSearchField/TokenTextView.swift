/*
 MIT License

 Copyright (c) 2016 Crosscoded (Kit Cross)

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
*/

import Cocoa

struct TokenSearchTypes {
  static let tokenizbleStemWords: [String] = [
    "from",
    "to",
    "subject",
    "label",
    "has",
    "list",
    "filename",
    "in",
    "has",
    "cc",
    "after",
    "before",
    "newer_than"]
}

class TokenTextView: NSTextView {
  var tokenizingCharacterSet: CharacterSet = CharacterSet.newlines

  func insertToken(attachment: NSTextAttachment, range: NSRange) {
    let replacementString: NSAttributedString = NSAttributedString(attachment: attachment)

    var rect: NSRect = firstRect(forCharacterRange: range, actualRange: nil)
    rect = (window?.convertFromScreen(rect))!
    rect.origin = convert(rect.origin, to: nil)

    textStorage?.replaceCharacters(in: range, with: replacementString)
  }

  func setHighlightedAtRanges(_ ranges: [NSRange], newHighlight: Bool) {
    guard let textStorage = self.textStorage else {
      return
    }

    for range in ranges {
      let intersection = NSIntersectionRange(NSMakeRange(0, textStorage.length), range)

      // if range is already deleted
      if (intersection.length == 0) {
        continue
      }

      textStorage.enumerateAttribute(NSAttachmentAttributeName,
                                      in: intersection,
                                      options: NSAttributedString.EnumerationOptions(),
                                      using: { (value: Any?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) in
                                        if let cell = (value as? NSTextAttachment)?.attachmentCell {
                                          if let tokenSearchField = (cell.attachment?.attachmentCell as? TokenAttachmentCell) {
                                            tokenSearchField.isHighlighted = newHighlight
                                          }
                                        }
      })
    }
  }

  override func setSelectedRanges(_ ranges: [NSValue], affinity: NSSelectionAffinity, stillSelecting stillSelectingFlag: Bool) {
    setHighlightedAtRanges(self.selectedRanges as [NSRange], newHighlight: false)
    setHighlightedAtRanges(ranges as [NSRange], newHighlight: true)
    super.setSelectedRanges(ranges, affinity: affinity, stillSelecting: stillSelectingFlag)
  }

  func tokenComponents(string: String)
    -> (stem: String?, value: String?) {

      let stringComponents = string.characters.split(separator: ":").flatMap(String.init)

      let tokenStem: String? = stringComponents.first?.trimmingCharacters(in: .whitespaces)
      let tokenValue: String? = stringComponents.last?.trimmingCharacters(in: .whitespaces)

      return (tokenStem, tokenValue)
  }

  func rangeOfTokenString(string: String) -> NSRange? {
    let string: NSString = string as NSString

    for (stem) in TokenSearchTypes.tokenizbleStemWords {
      let stemRange: NSRange = string.range(of: stem)
      if stemRange.location != NSNotFound {
        return NSRange(
          location: stemRange.location,
          length: string.length - stemRange.location
        )
      }
    }
    return nil
  }

  func makeToken(with event: NSEvent) {
    if let textString: String = textStorage?.string {
      if let tokenRange: NSRange = rangeOfTokenString(string: textString) {


        let textStringNew: NSString = textString as NSString

        let subString: String = textStringNew.substring(with: tokenRange)

        let (cellTitle, cellValue) = tokenComponents(string: subString)

        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.attachmentCell = TokenAttachmentCell(cellTitle: cellTitle!, cellValue: cellValue!)

        let string: NSAttributedString = NSAttributedString(attachment: attachment)
        let tokenString: NSMutableAttributedString = NSMutableAttributedString(attributedString: string)

        tokenString.addAttributes([
          NSFontAttributeName: NSFont.systemFont(ofSize: 13)
          ], range: NSRange(location: 0, length: tokenString.length))

        textStorage?.replaceCharacters(in: tokenRange, with: tokenString)

//        typingAttributes = [
//          NSFontAttributeName: NSFont.systemFont(ofSize: 14)
//        ]
      }
    }
  }

  override func keyDown(with event: NSEvent) {
    let index = event.characters?.startIndex
    let character = event.characters!

    if let characters = event.characters {
      let character = characters[index!]

      let stringOfCharacter = String(character)
      let scalars = stringOfCharacter.unicodeScalars

      let i = scalars.startIndex

      let scalar = scalars[i]

      if tokenizingCharacterSet.contains(scalar) {
        makeToken(with: event)
      } else {
        super.keyDown(with: event)
      }
    }
  }
}
