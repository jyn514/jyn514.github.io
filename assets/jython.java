import java.lang.reflect.Constructor;
import static java.util.Arrays.asList;

class main {
    public static void main(String[] args) throws ReflectiveOperationException {
        System.out.println(add(new NumberWrapper(4), new NumberWrapper(-.5)));
    }

    static <A, B> Object add(A a, B b) throws ReflectiveOperationException {
        return a.getClass().getMethod("add", Object.class).invoke(a, b);
    }

    public static class NumberWrapper {
        private final Number num;

        NumberWrapper(Number n) throws ReflectiveOperationException, IllegalArgumentException {
            Class c = n.getClass();
            for (Constructor bob : c.getConstructors()) {
                Class primaryField = bob.getParameterTypes()[0];
                if (primaryField == c ||
                    primaryField.isPrimitive() && !c.isPrimitive() && c.getDeclaredField("TYPE").get(c) == primaryField) {
                    num = (Number) bob.newInstance(n);
                    return;
                }
                System.out.println(bob);
                System.out.println(bob.getParameterTypes()[0]);
            }
            throw new IllegalArgumentException("No suitable constructor found for " + n + " of type " + c);
        }

        NumberWrapper(String s) { num = new Double(s); }

        public NumberWrapper add(Object t) throws ReflectiveOperationException {
            return new NumberWrapper(num.doubleValue()
                   + (double) t.getClass().getMethod("doubleValue").invoke(t));
        }

        public double doubleValue() {
            return num.doubleValue();
        }

        public String toString() {
            return num.toString();
        }
    }
}
