.check-version:
	@test $${VERSION?The VERSION variable must be set}

release/changelog: .check-version
	ruby scripts/changelog.rb "${VERSION}"

release/commit: .check-version
	git add .
	git commit -m "Release v${VERSION}"
	git push origin "$$(git rev-parse --abbrev-ref HEAD)"

release/tag: .check-version
	git tag -s -a -m "Release v${VERSION}" "v${VERSION}"
	git push origin "v${VERSION}"

release: release/changelog release/commit release/tag

.PHONY: release/changelog release/commit release/tag release
