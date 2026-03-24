import SwiftUI

struct TimerIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let r = min(rect.width, rect.height) * 0.42
        p.addEllipse(in: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
        let knobW: CGFloat = r * 0.3
        let knobH: CGFloat = r * 0.2
        p.addRoundedRect(in: CGRect(x: cx - knobW/2, y: cy - r - knobH, width: knobW, height: knobH), cornerSize: CGSize(width: 2, height: 2))
        return p
    }
}

struct HistoryIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let margin: CGFloat = w * 0.15
        for i in 0..<4 {
            let y = margin + CGFloat(i) * (h - 2 * margin) / 3
            p.addEllipse(in: CGRect(x: margin, y: y - 2, width: 4, height: 4))
            p.addRect(CGRect(x: margin + 8, y: y - 1, width: w - 2 * margin - 8, height: 2))
        }
        return p
    }
}

struct ChartIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let m: CGFloat = w * 0.15
        let barW = (w - 2 * m) / 5
        let heights: [CGFloat] = [0.4, 0.7, 0.5, 0.9, 0.6]
        for (i, ht) in heights.enumerated() {
            let x = m + CGFloat(i) * barW
            let barH = (h - 2 * m) * ht
            let y = h - m - barH
            p.addRoundedRect(in: CGRect(x: x + 1, y: y, width: barW - 2, height: barH), cornerSize: CGSize(width: 1, height: 1))
        }
        return p
    }
}

struct GearIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let outerR = min(rect.width, rect.height) * 0.42
        let innerR = outerR * 0.65
        let teethCount = 8
        for i in 0..<teethCount {
            let angle1 = Double(i) / Double(teethCount) * .pi * 2
            let angle2 = (Double(i) + 0.3) / Double(teethCount) * .pi * 2
            let angle3 = (Double(i) + 0.5) / Double(teethCount) * .pi * 2
            let angle4 = (Double(i) + 0.8) / Double(teethCount) * .pi * 2
            let p1 = CGPoint(x: cx + innerR * CGFloat(cos(angle1)), y: cy + innerR * CGFloat(sin(angle1)))
            let p2 = CGPoint(x: cx + outerR * CGFloat(cos(angle2)), y: cy + outerR * CGFloat(sin(angle2)))
            let p3 = CGPoint(x: cx + outerR * CGFloat(cos(angle3)), y: cy + outerR * CGFloat(sin(angle3)))
            let p4 = CGPoint(x: cx + innerR * CGFloat(cos(angle4)), y: cy + innerR * CGFloat(sin(angle4)))
            if i == 0 { p.move(to: p1) } else { p.addLine(to: p1) }
            p.addLine(to: p2)
            p.addLine(to: p3)
            p.addLine(to: p4)
        }
        p.closeSubpath()
        let holeR = innerR * 0.4
        p.addEllipse(in: CGRect(x: cx - holeR, y: cy - holeR, width: holeR * 2, height: holeR * 2))
        return p
    }
}

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.width * 0.2, y: rect.height * 0.55))
        p.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.75))
        p.addLine(to: CGPoint(x: rect.width * 0.8, y: rect.height * 0.25))
        return p
    }
}

struct ArrowLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.2))
        p.addLine(to: CGPoint(x: rect.width * 0.3, y: rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.8))
        return p
    }
}

struct ArrowRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.2))
        p.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.8))
        return p
    }
}

struct ExportIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        p.move(to: CGPoint(x: cx, y: rect.height * 0.15))
        p.addLine(to: CGPoint(x: cx - rect.width * 0.15, y: rect.height * 0.35))
        p.move(to: CGPoint(x: cx, y: rect.height * 0.15))
        p.addLine(to: CGPoint(x: cx + rect.width * 0.15, y: rect.height * 0.35))
        p.move(to: CGPoint(x: cx, y: rect.height * 0.15))
        p.addLine(to: CGPoint(x: cx, y: rect.height * 0.6))
        p.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.5))
        p.addLine(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.8))
        p.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.8))
        p.addLine(to: CGPoint(x: rect.width * 0.75, y: rect.height * 0.5))
        return p
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cx = rect.midX
        let cy = rect.midY
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * 0.4
        let points = 5
        for i in 0..<points * 2 {
            let r = i % 2 == 0 ? outerR : innerR
            let angle = Double(i) / Double(points * 2) * .pi * 2 - .pi / 2
            let pt = CGPoint(x: cx + r * CGFloat(cos(angle)), y: cy + r * CGFloat(sin(angle)))
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

struct ScaleIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Base platform
        p.addRoundedRect(in: CGRect(x: w * 0.1, y: h * 0.75, width: w * 0.8, height: h * 0.12), cornerSize: CGSize(width: 3, height: 3))
        // Stand
        p.addRect(CGRect(x: w * 0.42, y: h * 0.45, width: w * 0.16, height: h * 0.3))
        // Dial circle
        let dialR = w * 0.28
        let dialCx = w * 0.5
        let dialCy = h * 0.3
        p.addEllipse(in: CGRect(x: dialCx - dialR, y: dialCy - dialR, width: dialR * 2, height: dialR * 2))
        // Needle
        p.move(to: CGPoint(x: dialCx, y: dialCy))
        p.addLine(to: CGPoint(x: dialCx + dialR * 0.5, y: dialCy - dialR * 0.3))
        return p
    }
}

struct NoteIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        let m: CGFloat = w * 0.12
        // Page outline
        p.addRoundedRect(in: CGRect(x: m, y: m, width: w - 2 * m, height: h - 2 * m), cornerSize: CGSize(width: 3, height: 3))
        // Lines
        for i in 0..<3 {
            let y = m + (h - 2 * m) * 0.3 + CGFloat(i) * (h - 2 * m) * 0.18
            p.addRect(CGRect(x: m + w * 0.12, y: y, width: w * 0.5, height: 1.5))
        }
        return p
    }
}

struct PencilIconShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width
        let h = rect.height
        // Pencil body (diagonal)
        p.move(to: CGPoint(x: w * 0.7, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.85, y: h * 0.3))
        p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.8))
        p.addLine(to: CGPoint(x: w * 0.2, y: h * 0.65))
        p.closeSubpath()
        // Tip
        p.move(to: CGPoint(x: w * 0.2, y: h * 0.65))
        p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.8))
        p.addLine(to: CGPoint(x: w * 0.15, y: h * 0.85))
        p.closeSubpath()
        return p
    }
}
