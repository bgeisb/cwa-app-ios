//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

/// Error and ViewModel are dummies for the moment to construct the flow for the moment
/// needed to get replaced in later tasks
///
enum HealthCertifiedPersonUpdateError: Error {
	case UpdateFailedError
}

final class HealthCertificateReissuanceConsentViewModel {

	// MARK: - Init

	init(
		cclService: CCLServable,
		certificate: HealthCertificate,
		certifiedPerson: HealthCertifiedPerson,
		onDisclaimerButtonTap: @escaping () -> Void
	) {
		self.cclService = cclService
		self.certificate = certificate
		self.certifiedPerson = certifiedPerson
		self.onDisclaimerButtonTap = onDisclaimerButtonTap
	}

	// MARK: - Internal

	let title: String = AppStrings.HealthCertificate.Reissuance.Consent.title

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel(
			[
				.section(
					cells: [
						.certificate(certificate, certifiedPerson: certifiedPerson),
						titleDynamicCell,
						subtileDynamicCell,
						longTextDynamicCell
					]
						.compactMap({ $0 })
				),
				.section(
					cells: [
						.icon(
							UIImage(imageLiteralResourceName: "more_recycle_bin"),
							text: .string(AppStrings.HealthCertificate.Reissuance.Consent.deleteNotice),
							alignment: .top
						),
						.icon(
							UIImage(imageLiteralResourceName: "Icons_Certificates_01"),
							text: .string(AppStrings.HealthCertificate.Reissuance.Consent.cancelNotice),
							alignment: .top
						)
					]
				),
				.section(
					cells:
						[
							.legalExtended(
								title: NSAttributedString(string: AppStrings.HealthCertificate.Reissuance.Consent.legalTitle),
								subheadline1: attributedStringWithRegularText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalSubtitle),
								bulletPoints1: [
									attributedStringWithBoldText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalBullet1),
									attributedStringWithBoldText(text: AppStrings.HealthCertificate.Reissuance.Consent.legalBullet2)
								],
								subheadline2: nil
							),
							.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_1),
							.bulletPoint(text: AppStrings.HealthCertificate.Reissuance.Consent.bulletPoint_2),
							.space(height: 8.0),
							faqLinkDynamicCell,
							.space(height: 8.0)
						]
						.compactMap({ $0 })
				),
				.section(
					separators: .all,
					cells: [
						.body(
							text: AppStrings.HealthCertificate.Validation.body4,
							style: DynamicCell.TextCellStyle.label,
							accessibilityIdentifier: AccessibilityIdentifiers.TraceLocation.dataPrivacyTitle,
							accessibilityTraits: UIAccessibilityTraits.link,
							action: .execute { [weak self] _, _ in
								self?.onDisclaimerButtonTap()
							},
							configure: { _, cell, _ in
								cell.accessoryType = .disclosureIndicator
								cell.selectionStyle = .default
							}
						)
					]
				)
			]
		)
	}

	func markCertificateReissuanceAsSeen() {
		certifiedPerson.isNewCertificateReissuance = false
	}

	func submit(completion: @escaping (Result<Void, HealthCertifiedPersonUpdateError>) -> Void) {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
			// let's create a random result
			let success = Bool.random()
			if success {
				completion(.success(()))
			} else {
				completion(.failure(.UpdateFailedError))
			}
		}
	}

	// MARK: - Private

	private let cclService: CCLServable
	private let certificate: HealthCertificate
	private let certifiedPerson: HealthCertifiedPerson
	private let onDisclaimerButtonTap: () -> Void

	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]

	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]

	private func attributedStringWithRegularText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: normalTextAttribute)
	}

	private func attributedStringWithBoldText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: boldTextAttribute)
	}

	private var titleDynamicCell: DynamicCell? {
		guard let title = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.titleText?.localized(cclService: cclService) else {
			Log.info("title missing")
			return nil
		}
		return DynamicCell.title2(text: title)
	}

	private var subtileDynamicCell: DynamicCell? {
		guard let subtitle = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.subtitleText?.localized(cclService: cclService) else {
			Log.info("subtitle missing")
			return nil
		}
		return DynamicCell.subheadline(text: subtitle)
	}

	private var longTextDynamicCell: DynamicCell? {
		guard let longtext = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.longText?.localized(cclService: cclService) else {
			Log.info("long text missing")
			return nil
		}
		return DynamicCell.body(text: longtext)
	}

	private var faqLinkDynamicCell: DynamicCell? {
		guard let faqAnchor = certifiedPerson.dccWalletInfo?.certificateReissuance?.reissuanceDivision.faqAnchor else {
			Log.info("long text missing")
			return nil
		}
		return DynamicCell.link(
			text: AppStrings.HealthCertificate.Person.faq,
			url: URL(string: LinkHelper.urlString(suffix: faqAnchor, type: .faq))
		)
	}

}

private extension DynamicCell {
	static func certificate(_ certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) -> Self {
		.custom(withIdentifier: HealthCertificateCell.dynamicTableViewCellReuseIdentifier) { _, cell, _ in
			guard let cell = cell as? HealthCertificateCell else {
				return
			}
			cell.configure(
				HealthCertificateCellViewModel(
					healthCertificate: certificate,
					healthCertifiedPerson: certifiedPerson,
					details: .overviewPlusName
				),
				withDisclosureIndicator: false
			)
		}
	}
}