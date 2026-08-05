import android.os.IBinder;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Adds restricted permissions to Android's system allowlist.
 *
 * This is intentionally implemented through reflection so one small DEX can
 * work with both the older IPackageManager API and the newer
 * IPermissionManager API without linking against hidden framework stubs.
 */
public final class RestrictedPermissionTool {
    private static final int SYSTEM_ALLOWLIST = 1;

    private static final String[] ADD_METHODS = {
            "addAllowlistedRestrictedPermission",
            "addWhitelistedRestrictedPermission"
    };
    private static final String[] REMOVE_METHODS = {
            "removeAllowlistedRestrictedPermission",
            "removeWhitelistedRestrictedPermission"
    };
    private static final String[] LIST_METHODS = {
            "getAllowlistedRestrictedPermissions",
            "getWhitelistedRestrictedPermissions"
    };

    private static Object getService(String serviceName, String stubName) throws Exception {
        Class<?> serviceManager = Class.forName("android.os.ServiceManager");
        IBinder binder = (IBinder) serviceManager
                .getMethod("getService", String.class)
                .invoke(null, serviceName);
        if (binder == null) {
            return null;
        }

        Class<?> stub = Class.forName(stubName);
        return stub.getMethod("asInterface", IBinder.class).invoke(null, binder);
    }

    private static Method findMethod(Object service, String[] names, int parameterCount) {
        for (String name : names) {
            for (Method method : service.getClass().getMethods()) {
                if (method.getName().equals(name)
                        && method.getParameterTypes().length == parameterCount) {
                    return method;
                }
            }
        }
        return null;
    }

    private static final class ServiceMethod {
        final Object service;
        final Method method;

        ServiceMethod(Object service, Method method) {
            this.service = service;
            this.method = method;
        }
    }

    private static ServiceMethod findServiceMethod(String[] names, int parameterCount)
            throws Exception {
        Object service = null;
        try {
            service = getService(
                    "permissionmgr", "android.permission.IPermissionManager$Stub");
        } catch (ClassNotFoundException ignored) {
            // Android versions before the dedicated permission manager service.
        }
        if (service != null) {
            Method method = findMethod(service, names, parameterCount);
            if (method != null) {
                return new ServiceMethod(service, method);
            }
        }

        service = getService("package", "android.content.pm.IPackageManager$Stub");
        if (service != null) {
            Method method = findMethod(service, names, parameterCount);
            if (method != null) {
                return new ServiceMethod(service, method);
            }
        }

        throw new IllegalStateException(
                "restricted-permission allowlist API is unavailable");
    }

    private static Object invoke(Method method, Object receiver, Object... args)
            throws Exception {
        try {
            return method.invoke(receiver, args);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if (cause instanceof Exception) {
                throw (Exception) cause;
            }
            throw e;
        }
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("usage: <list|add|remove> PACKAGE [PERMISSION] [USER_ID]");
            System.exit(2);
        }

        String action = args[0];
        String packageName = args[1];

        if (action.equals("list")) {
            int userId = args.length >= 3 ? Integer.parseInt(args[2]) : 0;
            ServiceMethod target = findServiceMethod(LIST_METHODS, 3);
            Object result = invoke(
                    target.method, target.service,
                    packageName, SYSTEM_ALLOWLIST, userId);
            System.out.println(String.valueOf(result));
            return;
        }

        if (args.length < 3) {
            throw new IllegalArgumentException("permission name is required");
        }
        String permissionName = args[2];
        int userId = args.length >= 4 ? Integer.parseInt(args[3]) : 0;

        String[] methodNames;
        if (action.equals("add")) {
            methodNames = ADD_METHODS;
        } else if (action.equals("remove")) {
            methodNames = REMOVE_METHODS;
        } else {
            throw new IllegalArgumentException("unknown action: " + action);
        }

        ServiceMethod target = findServiceMethod(methodNames, 4);
        Object result = invoke(target.method, target.service, packageName, permissionName,
                SYSTEM_ALLOWLIST, userId);
        System.out.println(target.method.getName()
                + "(" + permissionName + ") => " + result);
    }
}
