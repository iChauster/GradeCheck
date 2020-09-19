package com.example.ivan.gradecheck_android;


import android.app.Activity;
import android.os.Build;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.util.Pair;
import android.view.View;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
/**
 * Created by ivan on 12/31/16.
 */

public class TransitionHelper {
        /**
         * Create the transition participants required during a activity transition while
         * avoiding glitches with the system UI.
         *
         * @param activity The activity used as start for the transition.
         * @param includeStatusBar If false, the status bar will not be added as the transition
         *        participant.
         * @return All transition participants.
         */
        public static Pair<View, String>[] createSafeTransitionParticipants(@NonNull Activity activity,
                                                                            boolean includeStatusBar, @Nullable Pair... otherParticipants) {
            // Avoid system UI glitches as described here:
            // https://plus.google.com/+AlexLockwood/posts/RPtwZ5nNebb
            View decor = activity.getWindow().getDecorView();
            View statusBar = null;
            if (includeStatusBar) {
                statusBar = decor.findViewById(android.R.id.statusBarBackground);
            }
            View navBar = decor.findViewById(android.R.id.navigationBarBackground);

            // Create pair of transition participants.
            List<Pair> participants = new ArrayList<>(3);
            addNonNullViewToTransitionParticipants(statusBar, participants);
            addNonNullViewToTransitionParticipants(navBar, participants);
            // only add transition participants if there's at least one none-null element
            if (otherParticipants != null && !(otherParticipants.length == 1
                    && otherParticipants[0] == null)) {
                participants.addAll(Arrays.asList(otherParticipants));
            }
            return participants.toArray(new Pair[participants.size()]);
        }

        private static void addNonNullViewToTransitionParticipants(View view, List<Pair> participants) {
            if (view == null) {
                return;
            }
            if(Build.VERSION.SDK_INT >= 21)
                participants.add(new Pair<>(view, view.getTransitionName()));
        }

    }

