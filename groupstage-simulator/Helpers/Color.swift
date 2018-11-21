/**
 *  Color.swift
 *  v2.9.1
 *
 *  Wrapper for UIColor, CGColor and CIColor.
 *  Includes a type for gradients (which exports to CALayer and CGGradientRef).
 *  Also includes an UIImage to create colored images.
 *
 *  Created by Freek Zijlmans, 2016-2017
 */


import UIKit
import CoreImage


// MARK: - Color struct
/// Color struct, holds red, green, blue and alpha as CGFloats. (32 bytes in total (yes, CGFloats are 64-bits))
public struct Color {
    
    public var red: CGFloat = 0
    public var green: CGFloat = 0
    public var blue: CGFloat = 0
    public var alpha: CGFloat = 1
    
    public init() {}
    
    // Initialize with CGFloats.
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    // Initialize with CGFloats (nameless).
    public init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) {
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    // Initialize with Ints.
    public init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    // Initialize with Ints (nameless).
    public init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    // Initialize grayscale (and alpha) with an Int (and CGFloat) (nameless).
    public init(_ gray: Int, alpha: CGFloat = 1.0) {
        let fgray = CGFloat(gray) / 255.0
        self.init(red: fgray, green: fgray, blue: fgray, alpha: alpha)
    }
    
    // Initialize grayscale (and alpha) with a CGFloat (nameless).
    public init(_ gray: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: gray, green: gray, blue: gray, alpha: alpha)
    }
    
    // Initialize color (and alpha) with a CGFloat (nameless).
    public init(_ color: Color, alpha: CGFloat = 1.0) {
        self.init(red: color.red, green: color.green, blue: color.blue, alpha: alpha)
    }
    
    // Initialize with a single 32-bit UInt (nameless). Useful for HEX codes! E.g: Color(0xFF8800) or Color(0xFF8800FF).
    public init(_ color: UInt32) {
        if color < (UInt32.max >> 8) { // RGB
            self.init(
                red: CGFloat(color >> 16 & 0xFF) / 0xFF,
                green: CGFloat(color >> 8 & 0xFF) / 0xFF,
                blue: CGFloat(color & 0xFF) / 0xFF
            )
        }
        else { // RGBA
            self.init(
                red: CGFloat(color >> 24 & 0xFF) / 0xFF,
                green: CGFloat(color >> 16 & 0xFF) / 0xFF,
                blue: CGFloat(color >> 8 & 0xFF) / 0xFF,
                alpha: CGFloat(color & 0xFF) / 0xFF
            )
        }
    }
    
    // Initialize with a string representing a 32 or 24-bit integer in hex.
    public init(_ color: String) {
        // Short
        var string = color.lowercased()
        if string.hasPrefix("#") {
            string = String(string[string.index(string.startIndex, offsetBy: 1)...])
        }
        
        let value = UInt32(string, radix: 16) ?? UInt32(0)
        self.init(value)
    }
    
    // Initialize with UIColor (nameless)
    public init(_ color: UIColor) {
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    // Initialize with CGColor (nameless)
    public init(_ color: CGColor) {
        let mem = color.components
        self.init(
            red: mem?[0] ?? 0,
            green: mem?[1] ?? 0,
            blue: mem?[2] ?? 0,
            alpha: mem?[3] ?? 1
        )
    }
    
    // Initialize with CIColor (nameless)
    public init(_ color: CIColor) {
        self.init(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }
    
    public var UI: UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var CG: CGColor {
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [red, green, blue, alpha])!
    }
    
    public var CI: CIColor {
        return CIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public var hex: String {
        return "#" + [red, green, blue].map { channel in
            let string = String(format: "%X", Int(channel * 255.0))
            return string.count == 1 ? "0" + string : string
        }.joined(separator: "")
    }
    
    public var int: Int32 {
        let r = Int32(red * 0xFF)
        let g = Int32(green * 0xFF)
        let b = Int32(blue * 0xFF)
        let a = Int32(alpha * 0xFF)
        return (((((r << 8) | g) << 8) | b) << 8) | a // Little endian.
    }
    
}

public func == (left: Color, right: Color) -> Bool {
    return left.red == right.red
        && left.green == right.green
        && left.blue == right.blue
        && left.alpha == right.alpha
}

extension Color: CustomStringConvertible {
    public var description: String {
        return "Red: \(red), green: \(green), blue: \(blue), alpha: \(alpha)"
    }
}

public func mix(_ from: Color, with: Color, at: CGFloat) -> Color {
    return Color(
        mix(from.red, with: with.red, at: at),
        mix(from.green, with: with.green, at: at),
        mix(from.blue, with: with.blue, at: at),
        mix(from.alpha, with: with.alpha, at: at)
    )
}

public func mix(_ from: CGFloat, with to: CGFloat, at pos: CGFloat) -> CGFloat {
    let travel = to - from
    return from + (travel * pos)
}

public func mix(_ from: Double, with to: Double, at pos: Double) -> Double {
    let travel = to - from
    return from + (travel * pos)
}

extension Color: Hashable {
    /// Basically returns the HEX code.
    public var hashValue: Int {
        let r = Int(red * 255) << 24
        let g = Int(green * 255) << 16
        let b = Int(blue * 255) << 8
        let a = Int(alpha * 255)
        return r | g | b | a
    }
}



// MARK: - ColorGradient struct.
/// Create a linear or radial gradient based on *n* amount of colors.
/// Can export a CGGradient and CAGradientLayer if you so desire.
public struct ColorGradient {
    
    public enum GradientType {
        case linear, radial
    }
    
    public typealias Segment = (color: Color, location: CGFloat)
    
    public var angle: CGFloat = 0
    
    public var segments: [Segment] = []
    
    public var type = GradientType.linear
    
    public init(segments: [Segment], type: GradientType = .linear, angle: CGFloat = 0) {
        self.angle = angle
        self.segments += segments
        self.type = type
    }
    
    public func layer(_ frame: CGRect) -> CALayer {
        let gradient = CAGradientLayer()
        gradient.colors = segments.map { $0.color.CG }
        gradient.frame = frame
        gradient.locations = segments.map { $0.location as NSNumber }
        
        if type == .linear {
            let xdist = cos(angle * (.pi / 180)) * 0.5
            let ydist = sin(angle * (.pi / 180)) * 0.5
            gradient.startPoint = CGPoint(x: 0.5 - xdist, y: 0.5 - ydist)
            gradient.endPoint = CGPoint(x: 0.5 + xdist, y: 0.5 + ydist)
        }
        else if type == .radial {
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        return gradient
    }
    
    public var CG: CGGradient {
        let locations = segments.map { $0.location }
        
        var colors: [CGFloat] = []
        for (color, _) in segments {
            colors += [color.red, color.green, color.blue, color.alpha]
        }
        
        let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors, locations: locations, count: segments.count)!
        return gradient
    }
    
}

public func == (left: ColorGradient, right: ColorGradient) -> Bool {
    if left.segments.count != right.segments.count {
        return false
    }
    
    for i in 0 ..< left.segments.count {
        if left.segments[i].color != right.segments[i].color
            || left.segments[i].location != right.segments[i].location
        {
            return false
        }
    }
    
    return true
}

extension ColorGradient: Hashable {
    public var hashValue: Int {
        return segments.reduce(0) { prev, seg in
            return prev + seg.color.hashValue
        }
    }
}

extension ColorGradient: CustomStringConvertible {
    public var description: String {
        var description = ""
        for segment in segments {
            description += segment.color.description + "\(segment.location)"
        }
        return description
    }
}



// MARK: - UIImage + ColoredImage.
public extension UIImage {
    
    /// Keep a weak reference to the colored image. Their key being the RGBA code as string.
    private static let dataBank = NSMapTable<NSString, UIImage>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    /// Colored image (based on a black/white image) filled with the given color.
    static func coloredImage(named name: String, color: Color) -> UIImage? {
        let keyName = name + color.description as NSString
        
        if let image = dataBank.object(forKey: keyName) {
            return image
        }
        else if let image = UIImage(named: name) {
            return modifyImage(image) { ctx, rect in
                ctx.setFillColor(color.CG)
                ctx.fill(rect)
            }
        }
        
        return nil
    }
    
    /// Colored image (based on a black/white image) filled with the given gradient.
    static func coloredImage(named name: String, gradient: ColorGradient) -> UIImage? {
        let keyName = name + gradient.description as NSString
        
        if let image = dataBank.object(forKey: keyName) {
            return image
        }
        else if let image = UIImage(named: name) {
            return modifyImage(image) { ctx, rect in
                let cggradient = gradient.CG
                if gradient.type == .linear {
                    let xdist = cos(gradient.angle * (.pi / 180)) * 0.5
                    let ydist = sin(gradient.angle * (.pi / 180)) * 0.5
                    let startPoint = CGPoint(x: 0.5 - xdist, y: 0.5 - ydist)
                    let endPoint = CGPoint(x: 0.5 + xdist, y: 0.5 + ydist)
                    
                    ctx.drawLinearGradient(cggradient, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
                }
                else if gradient.type == .radial {
                    ctx.drawRadialGradient(cggradient, startCenter: CGPoint(), startRadius: 0, endCenter: CGPoint(), endRadius: 1, options: .drawsBeforeStartLocation)
                }
            }
        }
        
        return nil
    }
    
    /// Helper to modify the image. All drawing is done in the `block` closure.
    private static func modifyImage(_ image: UIImage, block: (CGContext, CGRect) -> ()) -> UIImage? {
        guard let cgimage = image.cgImage else {
            return nil
        }
        
        let width = Int(image.size.width * image.scale)
        let height = Int(image.size.height * image.scale)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4 * width, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.clip(to: rect, mask: cgimage)
        block(ctx, rect)
        
        if let finalCGImage = ctx.makeImage() {
            return UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return nil
    }
    
}
