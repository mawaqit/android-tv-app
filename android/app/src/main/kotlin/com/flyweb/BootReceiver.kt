package com.mawaqit.androidtv

import android.content.BroadcastReceiver
import android.content.Context;
import android.content.Intent;

class BootReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val i = Intent(context, MainActivity::class.java)
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            i.addFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT)
            context.startActivity(i)
        }
    }
}