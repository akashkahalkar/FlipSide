import UIKit

enum FlatColors: String, CaseIterable {
    case Sunrise, Amin, Maldives, DIMIGO, NeonLife, BlueLagoon, Celestial, Kyoopal, SolidStone, GentleCare

    func colors() -> [UIColor] {
        switch  self {
        case .Sunrise:
            return [#colorLiteral(red: 0.9411764706, green: 0.5960784314, blue: 0, alpha: 1), #colorLiteral(red: 0.8941176471, green: 0.5764705882, blue: 0.1176470588, alpha: 1), #colorLiteral(red: 0.9647058824, green: 0.2745098039, blue: 0.2745098039, alpha: 1), #colorLiteral(red: 1, green: 0.3450980392, blue: 0.3450980392, alpha: 1)]
        case .Amin:
            return [#colorLiteral(red: 0.1450980392, green: 0.4588235294, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.1450980392, green: 0.4274509804, blue: 0.9019607843, alpha: 1), #colorLiteral(red: 0.4352941176, green: 0.1137254902, blue: 0.7843137255, alpha: 1), #colorLiteral(red: 0.4156862745, green: 0.06666666667, blue: 0.7960784314, alpha: 1)]
        case .Maldives:
            return [#colorLiteral(red: 0, green: 0.9490196078, blue: 0.9960784314, alpha: 1), #colorLiteral(red: 0.07058823529, green: 0.9019607843, blue: 0.9411764706, alpha: 1), #colorLiteral(red: 0.368627451, green: 0.6470588235, blue: 0.8901960784, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.4235294118, blue: 0.5450980392, alpha: 1)]
        case .DIMIGO:
            return [#colorLiteral(red: 0.9960784314, green: 0.3176470588, blue: 0.5882352941, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.2862745098, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.9098039216, green: 0.3647058824, blue: 0.3058823529, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.4235294118, blue: 0.5450980392, alpha: 1)]
        case .NeonLife:
            return [#colorLiteral(red: 0, green: 0.8901960784, blue: 0.6823529412, alpha: 1), #colorLiteral(red: 0.07843137255, green: 0.7960784314, blue: 0.6274509804, alpha: 1), #colorLiteral(red: 0.5333333333, green: 0.8078431373, blue: 0.2901960784, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.4235294118, blue: 0.5450980392, alpha: 1)]
        case .BlueLagoon:
            return [#colorLiteral(red: 0.2, green: 0.03137254902, blue: 0.4039215686, alpha: 1), #colorLiteral(red: 0.2666666667, green: 0.1529411765, blue: 0.4039215686, alpha: 1), #colorLiteral(red: 0.1411764706, green: 0.5725490196, blue: 0.5764705882, alpha: 1), #colorLiteral(red: 0.1882352941, green: 0.8117647059, blue: 0.8156862745, alpha: 1)]
        case .Celestial:
            return [#colorLiteral(red: 0.007843137255, green: 0.3137254902, blue: 0.7725490196, alpha: 1), #colorLiteral(red: 0.168627451, green: 0.3450980392, blue: 0.6078431373, alpha: 1), #colorLiteral(red: 0.7215686275, green: 0.2196078431, blue: 0.4823529412, alpha: 1), #colorLiteral(red: 0.831372549, green: 0.2470588235, blue: 0.5529411765, alpha: 1)]
        case .Kyoopal:
            return [#colorLiteral(red: 0.1411764706, green: 0.8235294118, blue: 0.5725490196, alpha: 1), #colorLiteral(red: 0.1215686275, green: 0.7725490196, blue: 0.5333333333, alpha: 1), #colorLiteral(red: 0.7607843137, green: 0.2941176471, blue: 0.7137254902, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0.3450980392, blue: 0.7843137255, alpha: 1)]
        case .SolidStone:
            return [#colorLiteral(red: 0.3176470588, green: 0.4980392157, blue: 0.6431372549, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.4235294118, blue: 0.5450980392, alpha: 1), #colorLiteral(red: 0.1764705882, green: 0.2352941176, blue: 0.2784313725, alpha: 1), #colorLiteral(red: 0.1411764706, green: 0.2235294118, blue: 0.2862745098, alpha: 1)]
        case .GentleCare:
            return [#colorLiteral(red: 1, green: 0.6862745098, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.9019607843, green: 0.6117647059, blue: 0.662745098, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.6509803922, blue: 0.4980392157, alpha: 1), #colorLiteral(red: 0.2745098039, green: 0.4235294118, blue: 0.5450980392, alpha: 1)]
        }
    }

    var primaryColors: [UIColor] {
        let palette = colors()
        if palette.count >= 2 {
            return [palette[0], palette[1]]
        }
        if let first = palette.first {
            return [first, first]
        }
        return [UIColor.systemBackground, UIColor.systemBackground]
    }

    var secondaryColors: [UIColor] {
        let palette = colors()
        if palette.count >= 4 {
            return [palette[2], palette[3]]
        }
        if palette.count >= 2 {
            return [palette[1], palette[0]]
        }
        if let first = palette.first {
            return [first, first]
        }
        return [UIColor.secondarySystemBackground, UIColor.secondarySystemBackground]
    }
}

enum GradientPoints: Int {
    case left
    case top
    case right
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    var point: CGPoint {
        switch self {
        case .top: return CGPoint(x: 0.5, y: 0.0)
        case .left: return CGPoint(x: 0.0, y: 0.5)
        case .right: return CGPoint(x: 1.0, y: 0.5)
        case .bottom: return CGPoint(x: 0.5, y: 1.0)
        case .topLeft: return CGPoint(x: 0.0, y: 0.0)
        case .topRight: return CGPoint(x: 1.0, y: 0.0)
        case .bottomLeft: return CGPoint(x: 0.0, y: 1.0)
        case .bottomRight: return CGPoint(x: 1.0, y: 1.0)
        }
    }
}
