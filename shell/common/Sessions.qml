pragma Singleton

import QtQuick

QtObject {
	property var owner: null

	function claim(surface) {
		const previous = owner
		owner = surface
		if (previous && previous !== surface)
			previous.dismiss()
	}

	function release(surface) {
		if (owner === surface)
			owner = null
	}
}
