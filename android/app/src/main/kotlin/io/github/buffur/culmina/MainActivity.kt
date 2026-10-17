package io.github.buffur.culmina

import android.animation.ValueAnimator
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.window.SplashScreenView
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.time.Duration
import java.time.Instant

class MainActivity : FlutterActivity() {
    // S2.4 (ADR-017 §6): capture files are opened for metadata without a copy.
    private var documents: MetadataDocumentChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // S13.3 (ID-6 as amended by the owner, 2026-10-17): on Android 12+ the
        // splash stays until its one-second animation has played, then fades
        // out; the app keeps loading underneath. With animations off nothing is
        // held. Platform API only (no new package).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { view -> exitSplash(view) }
        }
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun exitSplash(view: SplashScreenView) {
        val start: Instant? = view.iconAnimationStart
        val length: Duration? = view.iconAnimationDuration
        val remaining = if (ValueAnimator.areAnimatorsEnabled() && start != null && length != null) {
            (length.toMillis() - Duration.between(start, Instant.now()).toMillis()).coerceIn(0, 1000)
        } else {
            0L
        }
        if (!ValueAnimator.areAnimatorsEnabled()) {
            view.remove()
            return
        }
        // The mark fades first, on the navy background, so it never shows over
        // the app; then the background fades into the app.
        val fadeBackground = {
            view.animate().alpha(0f).setDuration(150L).withEndAction { view.remove() }.start()
        }
        val icon = view.iconView
        if (icon == null) {
            view.postDelayed(fadeBackground, remaining)
        } else {
            icon.animate()
                .alpha(0f)
                .setStartDelay(remaining)
                .setDuration(120L)
                .withEndAction(fadeBackground)
                .start()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        documents = MetadataDocumentChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        documents?.dispose()
        documents = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (documents?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }
}
