import Alpine from 'alpinejs'
import FormsAlpinePlugin from '../../../vendor/filament/forms/dist/index.js'
import NotificationsAlpinePlugin from '../../../vendor/filament/notifications/dist/index.js'

Alpine.plugin(FormsAlpinePlugin)
Alpine.plugin(NotificationsAlpinePlugin)

window.Alpine = Alpine

Alpine.start()
