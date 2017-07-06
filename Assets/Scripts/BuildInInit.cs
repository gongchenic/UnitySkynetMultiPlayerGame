namespace XLua.LuaDLL
{
    using System.Runtime.InteropServices;

    public partial class Lua
    {
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_protobuf_c(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadProtobufC(System.IntPtr L)
        {
            return luaopen_protobuf_c(L);
        }
    }
}