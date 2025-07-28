import UIKit

public enum PieChart {
    public static let segmentColors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemGreen,
        .systemOrange,
        .systemPurple,
        .systemGray
    ]
}

public final class PieChartView: UIView {

    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), !entities.isEmpty else { return }

        let radius = min(bounds.width, bounds.height) * 0.4
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let lineWidth: CGFloat = 8

        let total = entities.map { NSDecimalNumber(decimal: $0.value).doubleValue }.reduce(0, +)
        guard total > 0 else { return }

        var angles: [Double] = []
        var labels: [String] = []
        var values: [Double] = []

        let top5 = entities.prefix(5)
        let rest = entities.dropFirst(5)

        for e in top5 {
            let v = NSDecimalNumber(decimal: e.value).doubleValue
            angles.append(v / total)
            labels.append(e.label)
            values.append(v)
        }

        if !rest.isEmpty {
            let v = rest.map { NSDecimalNumber(decimal: $0.value).doubleValue }.reduce(0, +)
            angles.append(v / total)
            labels.append("Остальные")
            values.append(v)
        }

        var startAngle = -CGFloat.pi / 2

        for (index, angleFraction) in angles.enumerated() {
            let endAngle = startAngle + CGFloat(angleFraction) * 2 * .pi

            context.setStrokeColor(PieChart.segmentColors[index % PieChart.segmentColors.count].cgColor)
            context.setLineWidth(lineWidth)
            context.setLineCap(.butt)

            let path = UIBezierPath(arcCenter: center,
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: true)
            path.lineWidth = lineWidth
            path.stroke()

            startAngle = endAngle
        }

        drawCenteredLegend(labels: labels, values: values)
    }

    private func drawCenteredLegend(labels: [String], values: [Double]) {
        let font = UIFont.systemFont(ofSize: 7, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.label
        ]

        let total = values.reduce(0, +)
        guard total > 0 else { return }

        let spacing: CGFloat = 4
        let circleSize: CGFloat = 6
        let lineHeight: CGFloat = 10

        let lines: [String] = zip(labels, values).map { label, value in
            let percent = Int((value / total) * 100)
            return "\(percent)% \(label)"
        }

        let maxWidth = lines.map {
            ($0 as NSString).size(withAttributes: attributes).width
        }.max() ?? 0

        let totalHeight = CGFloat(lines.count) * (lineHeight + spacing) - spacing
        let startY = bounds.midY - totalHeight / 2

        for (i, text) in lines.enumerated() {
            let y = startY + CGFloat(i) * (lineHeight + spacing)

            let textSize = (text as NSString).size(withAttributes: attributes)

            let totalLineWidth = circleSize + 6 + textSize.width
            let startX = bounds.midX - totalLineWidth / 2

            let color = PieChart.segmentColors[i % PieChart.segmentColors.count]
            let circleRect = CGRect(x: startX, y: y + (lineHeight - circleSize) / 2, width: circleSize, height: circleSize)

            let circlePath = UIBezierPath(ovalIn: circleRect)
            color.setFill()
            circlePath.fill()

            let textOrigin = CGPoint(x: circleRect.maxX + 6, y: y)
            let textRect = CGRect(origin: textOrigin, size: textSize)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

extension PieChartView {
    public func setEntities(_ newEntities: [Entity], animated: Bool) {
        guard animated else {
            self.entities = newEntities
            return
        }

        let oldSnapshot = snapshotView(afterScreenUpdates: false)
        oldSnapshot?.frame = bounds
        oldSnapshot?.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        oldSnapshot?.center = CGPoint(x: bounds.midX, y: bounds.midY)
        oldSnapshot?.alpha = 1
        oldSnapshot?.transform = .identity

        if let oldSnapshot = oldSnapshot {
            addSubview(oldSnapshot)
        }

        self.entities = newEntities
        setNeedsDisplay()
        layoutIfNeeded()

        self.alpha = 0
        self.transform = CGAffineTransform(rotationAngle: .pi)

        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5) {
                oldSnapshot?.alpha = 0
                oldSnapshot?.transform = CGAffineTransform(rotationAngle: .pi)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                self.alpha = 1
                self.transform = .identity
            }
        }, completion: { _ in
            oldSnapshot?.removeFromSuperview()
        })
    }
}
