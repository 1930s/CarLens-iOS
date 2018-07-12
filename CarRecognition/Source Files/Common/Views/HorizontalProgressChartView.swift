//
//  HorizontalProgressChartView.swift
//  CarRecognition
//


import UIKit
import Lottie

internal final class HorizontalProgressChartView: View, ViewSetupable {
    
    /// States available to display by this view
    enum State {
        case power(Int)
        case engine(Int)
    }
    
    private var state: State
    
    private var isLocked: Bool
    
    private let chartConfig = CarSpecificationChartConfiguration()
    
    private lazy var animationView = LOTAnimationView(name: "horizontal-progress-chart").layoutable()
    
    private lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.font = .gliscorGothicFont(ofSize: 20)
        view.textColor = .crFontDark
        view.numberOfLines = 1
        view.textAlignment = .left
        return view.layoutable()
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .gliscorGothicFont(ofSize: 12)
        view.textColor = .crFontGray
        view.numberOfLines = 1
        view.textAlignment = .left
        return view.layoutable()
    }()
    
    /// Initializes the view with given state
    ///
    /// - Parameters:
    ///   - state: State to be shown by the view
    ///   - invalidateChartInstantly: Chart will be updated instantly without animation if this value indicates false.
    ///                               When passing false, remember to use method `invalidatChart(animated:)` also
    ///   - isLocked: Indicating if the info should be locked
    init(state: State, invalidateChartInstantly: Bool, isLocked: Bool = false) {
        self.state = state
        self.isLocked = isLocked
        super.init()
        setup(state: state, invalidateChartInstantly: invalidateChartInstantly, isLocked: isLocked)
    }
    
    /// Setups the view with given state. Use only inside reusable views.
    ///
    /// - Parameters:
    ///   - state: State to be shown by the view
    ///   - invalidateChartInstantly: Chart will be updated instantly without animation if this value indicates false.
    ///                               When passing false, remember to use method `invalidatChart(animated:)` also
     ///   - isLocked: Indicating if the info should be locked
    func setup(state: State, invalidateChartInstantly: Bool, isLocked: Bool = false) {
        animationView.set(progress: 0, animated: false)
        self.state = state
        self.isLocked = isLocked
        switch state {
        case .power(let power):
            let valueText = String(power) + "\(Localizable.CarCard.hp)"
            valueLabel.attributedText = NSAttributedStringFactory.trackingApplied(valueText, font: valueLabel.font, tracking: 0.6)
            titleLabel.text = Localizable.CarCard.power.uppercased()
        case .engine(let engine):
            let valueText = "\(engine)\(Localizable.CarCard.cc)"
            valueLabel.attributedText = NSAttributedStringFactory.trackingApplied(valueText, font: valueLabel.font, tracking: 0.6)
            titleLabel.text = Localizable.CarCard.engine.uppercased()
        }
        if invalidateChartInstantly {
            invalidateChart(animated: false)
        }
        valueLabel.textColor = isLocked ? .crFontGrayLocked : .crFontDark
        if isLocked {
            valueLabel.text = "?"
        }
    }
    
    /// Invalidates the progress shown on the chart
    ///
    /// - Parameter animated: Indicating if invalidation should be animated
    func invalidateChart(animated: Bool) {
        var progress: Double
        switch state {
        case .power(let power):
            progress = Double(power) / Double(chartConfig.referenceHorsePower)
        case .engine(let engine):
            progress = Double(engine) / Double(chartConfig.referenceEngineVolume)
        }
        if isLocked {
            progress = 0
        }
        animationView.set(progress: CGFloat(progress), animated: animated)
    }
    
    /// Clear the progress shown on the chart
    ///
    /// - Parameter animated: Indicating if progress change should be animated
    func clearChart(animated: Bool) {
        animationView.set(progress: 0, animated: animated)
    }
    
    /// - SeeAlso: ViewSetupable
    func setupViewHierarchy() {
        [animationView, valueLabel, titleLabel].forEach(addSubview)
    }
    
    /// - SeeAlso: ViewSetupable
    func setupConstraints() {
        titleLabel.constraintToSuperviewEdges(excludingAnchors: [.bottom])
        valueLabel.constraintToSuperviewEdges(excludingAnchors: [.top, .bottom])
        animationView.constraintToSuperviewEdges(excludingAnchors: [.top])
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: animationView.topAnchor, constant: 3),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -3)
        ])
    }
}
