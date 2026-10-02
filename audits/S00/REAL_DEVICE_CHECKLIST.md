# S00 real-device checklist

Use one physical iPhone with a development-signed build containing the app, monitor extension, and report extension. Record iOS/build version and wall-clock observations. Reset the experiment by stopping and starting monitoring; S00 deliberately sets `includesPastActivity=false`, so selected-app use before each start is excluded.

## 1. Authorization and picker

- Request individual Family Controls authorization and notification permission.
- Select at least two applications in Apple's picker; relaunch Elapse and confirm the opaque selection count persists.
- Start monitoring and record success/error. Expected thresholds: 5/10/15/20/25/30 minutes.

## 2. Shared pool

- Use selected App A for about 2 minutes, then selected App B until combined selected usage crosses 5 minutes.
- Record separately: OS threshold callback seen in device logs; notification request accepted in logs; banner/alert visibly observed.

## 3. Unselected time

- Stop/start to reset. Use a selected app briefly, then spend at least 5 minutes in an unselected app or locked, then resume selected use.
- Record whether behavior suggests that unselected/locked wall-clock time was incorrectly counted.

## 4. Sequential thresholds

- Continue selected-app use through 10, 15, 20, 25, and 30 minutes.
- For each boundary record callback receipt time, request result, visible notification, and whether it was early, delayed, missing, or duplicated.

## 5. Switching and lock

- Switch repeatedly among both selected apps, an unselected app, and lock/unlock.
- Record missing, duplicate, early, or delayed callbacks without normalizing them away.

## 6. Restart and authorization

- Stop/start monitoring, relaunch Elapse, and—if practical—reboot the iPhone.
- Revoke and regrant Family Controls authorization. Record stale callbacks, duplicates, monitoring state, and errors.

## 7. Report truthfulness

- Open Today. Compare rough observed use with each selected app row and hourly bars.
- Confirm rows use Apple's private labels, buckets are labeled hourly aggregates, and no UI implies exact app-open/app-close sessions.

## Result rule

Do not mark a gate PASS from compilation, Simulator, notification-request acceptance, or a visible banner alone. Attach only privacy-safe timestamps and observations to `RESULTS.md`.
