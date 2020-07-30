import jni;
extern(C) jstring Java_my_long_package_name_ClassName_methodname(JNIEnv* env, jclass clazz, jstring stringArgReceivedFromJava)
{
    return (*env).NewUTFString("Hello from D");
}
void main(){}