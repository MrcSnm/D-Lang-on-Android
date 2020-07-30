import jni;
import std.conv : to;
import std.string;
import core.runtime : rt_init;
extern(C) jstring Java_my_long_package_name_ClassName_methodname(JNIEnv* env, jclass clazz, jstring stringArgReceivedFromJava)
{
    rt_init();
    const char* javaStringInCStyle = (*env).GetStringUTFChars(env, stringArgReceivedFromJava, null);
    string javaStringInDStyle = to!string(javaStringInCStyle);
    (*env).ReleaseStringUTFChars(env, stringArgReceivedFromJava, javaStringInCStyle);

    return (*env).NewUTFString(toStringz("Hello from D, myarg: "~javaStringInDStyle));
}
void main(){}