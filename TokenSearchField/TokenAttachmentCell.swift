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

class TokenAttachmentCell: NSTextAttachmentCell {

  let cellMarginSide: CGFloat = 4.0
  let cellDivider: CGFloat = 0.5
  var cellTitleString: String

  init(cellTitle: String, cellValue: String) {
    cellTitleString = cellTitle.uppercased()
    super.init(textCell: cellValue)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var cellSize: NSSize {
    let titleSize = NSSize(
      width: (cellTitleSize().width + cellValueSize().width) + cellDivider,
      height: cellValueSize().height)

    return titleSize
  }

  func cellTitleSize() -> NSSize {
    let font: NSFont = NSFont.systemFont(ofSize: 9.0, weight: NSFontWeightMedium)

    let titleStringSize: NSSize = cellTitleString.size(withAttributes: [
      NSFontAttributeName: font
    ])

    return NSSize(
      width: titleStringSize.width + (cellMarginSide * 2),
      height: titleStringSize.height
    )
  }

  func cellValueSize() -> NSSize {
    let valueStringSize: NSSize = stringValue.size(withAttributes: [
      NSFontAttributeName: font!
    ])

    return NSSize(
      width: valueStringSize.width + (cellMarginSide * 3),
      height: valueStringSize.height
    )
  }

  override func cellBaselineOffset() -> NSPoint {
    if let descender: CGFloat = self.font?.descender {
      return NSPoint(x: 0.0, y: descender)
    }
    return NSPoint(x: 0.0, y: 0.0)
  }

  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
    NSColor.init(red: 0.85, green: 0.85, blue: 0.87, alpha: 1.0).set()

    if isHighlighted {
      NSColor.init(red: 0.62, green: 0.63, blue: 0.64, alpha: 1.0).set()
    }

    let tokenTitlePath: NSBezierPath = tokenTitlePathForBounds(bounds: cellFrame)

    NSGraphicsContext.current()?.saveGraphicsState()

    tokenTitlePath.addClip()
    tokenTitlePath.fill()

    NSGraphicsContext.current()?.restoreGraphicsState()

    NSColor.init(red: 0.92, green: 0.92, blue: 0.93, alpha: 1.0).set()

    if isHighlighted {
      NSColor.init(red: 0.62, green: 0.63, blue: 0.64, alpha: 1.0).set()
    }

    NSGraphicsContext.current()?.saveGraphicsState()

    let tokenValuePath: NSBezierPath = tokenValuePathForBounds(bounds: cellFrame)
    tokenValuePath.addClip()
    tokenValuePath.fill()

    NSGraphicsContext.current()?.restoreGraphicsState()

    var textColor: NSColor

    if isHighlighted {
      textColor = NSColor.white
    } else {
      textColor = NSColor(white: 0.30, alpha: 1.0)
    }

    let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = NSLineBreakMode.byClipping

    cellTitleString.draw(at: CGPoint(
        x: cellFrame.origin.x + cellMarginSide,
        y: cellFrame.origin.y + 2),
      withAttributes: [
        NSFontAttributeName: NSFont.systemFont(ofSize: 9, weight: NSFontWeightMedium),
        NSForegroundColorAttributeName: textColor,
        NSParagraphStyleAttributeName: paragraphStyle
    ])

    stringValue.draw(at: CGPoint(
        x: cellFrame.origin.x + cellTitleSize().width + 0.5 + cellMarginSide,
        y: cellFrame.origin.y - 1),
      withAttributes: [
        NSFontAttributeName: NSFont.systemFont(ofSize: 13),
        NSForegroundColorAttributeName: textColor,
        NSParagraphStyleAttributeName: paragraphStyle
    ])
  }

  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?,
                     characterIndex charIndex: Int, layoutManager: NSLayoutManager) {

//    print("draw with character index")

//    if controlView?.responds(to: #selector(selectedRanges:)) {
//      print(controlView.selectedRanges)
//    }

    draw(withFrame: cellFrame, in: controlView)
  }

  override func draw(withFrame cellFrame: NSRect, in controlView: NSView?,
                     characterIndex charIndex: Int) {

    if let textField = controlView as? NSSearchField {
      print(textField.currentEditor()?.selectedRange)
    }

    draw(withFrame: cellFrame, in: controlView)
  }

  override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView?) {

    if (!isHighlighted) {
      isHighlighted = true
    } else {
      isHighlighted = false
    }

    controlView?.setNeedsDisplay(cellFrame)
  }

  func tokenTitlePathForBounds(bounds: NSRect) -> NSBezierPath {

    let titleBoundsRect: NSRect = NSRect(
      x: bounds.origin.x,
      y: bounds.origin.y,
      width: cellTitleSize().width,
      height: bounds.size.height)

    let xMin: CGFloat = titleBoundsRect.minX
    let xMax: CGFloat = titleBoundsRect.maxX

    let yMin: CGFloat = titleBoundsRect.minY + 0.5
    let yMax: CGFloat = titleBoundsRect.maxY

    let path: NSBezierPath = NSBezierPath()

    path.move(to: NSPoint(x: xMax, y: yMin))
    path.line(to: NSPoint(x: xMax, y: yMax))

    path.appendArc(
      withCenter: NSPoint(x: xMin + 3, y: yMax - 3),
      radius: 3,
      startAngle: 90,
      endAngle: 180,
      clockwise: false
    )

    path.appendArc(
      withCenter: NSPoint(x: xMin + 3, y: yMin + 3),
      radius: 3,
      startAngle: 180,
      endAngle: 270,
      clockwise: false
    )
    path.close()

    return path
  }

  func tokenValuePathForBounds(bounds: NSRect) -> NSBezierPath {

    let valueBoundsRect: NSRect = NSRect(
      x: bounds.origin.x + (cellTitleSize().width + 1),
      y: bounds.origin.y,
      width: cellValueSize().width,
      height: bounds.size.height)

    let xMin: CGFloat = valueBoundsRect.minX
    let xMax: CGFloat = valueBoundsRect.maxX

    let yMin: CGFloat = valueBoundsRect.minY + 0.5
    let yMax: CGFloat = valueBoundsRect.maxY

    let path: NSBezierPath = NSBezierPath()

    path.move(to: NSPoint(x: xMin, y: yMin))
    path.line(to: NSPoint(x: xMin, y: yMax))

    path.appendArc(
      withCenter: NSPoint(x: xMax - 3, y: yMax - 3),
      radius: 3,
      startAngle: 90,
      endAngle: 0,
      clockwise: true
    )

    path.appendArc(
      withCenter: NSPoint(x: xMax - 3, y: yMin + 3),
      radius: 3,
      startAngle: 0,
      endAngle: 270,
      clockwise: true
    )
    path.close()

    return path
  }

  override func wantsToTrackMouse() -> Bool {
    return true
  }

  override func wantsToTrackMouse(for theEvent: NSEvent,
                                  in cellFrame: NSRect,
                                  of controlView: NSView?,
                                  atCharacterIndex charIndex: Int) -> Bool {
    return true
  }

  override func trackMouse(with theEvent: NSEvent,
                           in cellFrame: NSRect,
                           of controlView: NSView?,
                           atCharacterIndex charIndex: Int,
                           untilMouseUp flag: Bool) -> Bool {
    highlight(flag, withFrame: cellFrame, in: controlView)
    return theEvent.type == NSEventType.leftMouseDown
  }

  override func trackMouse(with theEvent: NSEvent,
                           in cellFrame: NSRect,
                           of controlView: NSView?,
                           untilMouseUp flag: Bool) -> Bool {
    return true
  }

}
