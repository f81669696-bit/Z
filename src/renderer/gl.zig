const std = @import("std");

// OpenGL 3.3 Core function pointers
// Loaded at runtime via SDL_GL_GetProcAddress

pub const GLuint   = u32;
pub const GLint    = i32;
pub const GLfloat  = f32;
pub const GLenum   = u32;
pub const GLsizei  = i32;
pub const GLboolean= u8;
pub const GLchar   = u8;
pub const GLvoid   = anyopaque;
pub const GLsizeiptr = isize;
pub const GLbitfield = u32;

pub const TRUE:  GLboolean = 1;
pub const FALSE: GLboolean = 0;

// Buffer targets
pub const ARRAY_BUFFER:         GLenum = 0x8892;
pub const ELEMENT_ARRAY_BUFFER: GLenum = 0x8893;

// Usage hints
pub const STATIC_DRAW:  GLenum = 0x88B4;
pub const DYNAMIC_DRAW: GLenum = 0x88E8;
pub const STREAM_DRAW:  GLenum = 0x88E0;

// Primitive types
pub const TRIANGLES: GLenum = 0x0004;
pub const LINES:     GLenum = 0x0001;
pub const POINTS:    GLenum = 0x0000;

// Data types
pub const FLOAT:          GLenum = 0x1406;
pub const UNSIGNED_INT:   GLenum = 0x1405;
pub const UNSIGNED_BYTE:  GLenum = 0x1401;
pub const UNSIGNED_SHORT: GLenum = 0x1403;

// Shader types
pub const VERTEX_SHADER:   GLenum = 0x8B31;
pub const FRAGMENT_SHADER: GLenum = 0x8B30;
pub const COMPILE_STATUS:  GLenum = 0x8B81;
pub const LINK_STATUS:     GLenum = 0x8B82;
pub const INFO_LOG_LENGTH: GLenum = 0x8B84;

// Texture
pub const TEXTURE_2D:           GLenum = 0x0DE1;
pub const TEXTURE_2D_ARRAY:     GLenum = 0x8C1A;
pub const TEXTURE_WRAP_S:       GLenum = 0x2802;
pub const TEXTURE_WRAP_T:       GLenum = 0x2803;
pub const TEXTURE_MIN_FILTER:   GLenum = 0x2801;
pub const TEXTURE_MAG_FILTER:   GLenum = 0x2800;
pub const NEAREST:              GLenum = 0x2600;
pub const LINEAR:               GLenum = 0x2601;
pub const CLAMP_TO_EDGE:        GLenum = 0x812F;
pub const REPEAT:               GLenum = 0x2901;
pub const RGBA:                 GLenum = 0x1908;
pub const RGB:                  GLenum = 0x1907;
pub const RGBA8:                GLenum = 0x8058;
pub const TEXTURE0:             GLenum = 0x84C0;
pub const UNPACK_ALIGNMENT:     GLenum = 0x0CF5;

// Depth / blend
pub const DEPTH_TEST:           GLenum = 0x0B71;
pub const BLEND:                GLenum = 0x0BE2;
pub const CULL_FACE:            GLenum = 0x0B44;
pub const BACK:                 GLenum = 0x0405;
pub const LEQUAL:               GLenum = 0x0203;
pub const SRC_ALPHA:            GLenum = 0x0302;
pub const ONE_MINUS_SRC_ALPHA:  GLenum = 0x0303;
pub const DEPTH_BUFFER_BIT:     GLbitfield = 0x0100;
pub const COLOR_BUFFER_BIT:     GLbitfield = 0x4000;

// Function pointer table — filled by init()
var _GenVertexArrays:  ?*const fn(GLsizei, [*]GLuint) callconv(.C) void = null;
var _BindVertexArray:  ?*const fn(GLuint) callconv(.C) void = null;
var _GenBuffers:       ?*const fn(GLsizei, [*]GLuint) callconv(.C) void = null;
var _BindBuffer:       ?*const fn(GLenum, GLuint) callconv(.C) void = null;
var _BufferData:       ?*const fn(GLenum, GLsizeiptr, ?*const GLvoid, GLenum) callconv(.C) void = null;
var _BufferSubData:    ?*const fn(GLenum, GLsizeiptr, GLsizeiptr, ?*const GLvoid) callconv(.C) void = null;
var _EnableVertexAttribArray: ?*const fn(GLuint) callconv(.C) void = null;
var _VertexAttribIPointer: ?*const fn(GLuint, GLint, GLenum, GLsizei, usize) callconv(.C) void = null;
var _DrawArrays:       ?*const fn(GLenum, GLint, GLsizei) callconv(.C) void = null;
var _DrawElements:     ?*const fn(GLenum, GLsizei, GLenum, usize) callconv(.C) void = null;
var _CreateShader:     ?*const fn(GLenum) callconv(.C) GLuint = null;
var _ShaderSource:     ?*const fn(GLuint, GLsizei, [*]const [*]const GLchar, ?[*]const GLint) callconv(.C) void = null;
var _CompileShader:    ?*const fn(GLuint) callconv(.C) void = null;
var _GetShaderiv:      ?*const fn(GLuint, GLenum, [*]GLint) callconv(.C) void = null;
var _GetShaderInfoLog: ?*const fn(GLuint, GLsizei, ?*GLsizei, [*]GLchar) callconv(.C) void = null;
var _CreateProgram:    ?*const fn() callconv(.C) GLuint = null;
var _AttachShader:     ?*const fn(GLuint, GLuint) callconv(.C) void = null;
var _LinkProgram:      ?*const fn(GLuint) callconv(.C) void = null;
var _GetProgramiv:     ?*const fn(GLuint, GLenum, [*]GLint) callconv(.C) void = null;
var _UseProgram:       ?*const fn(GLuint) callconv(.C) void = null;
var _DeleteShader:     ?*const fn(GLuint) callconv(.C) void = null;
var _GetUniformLocation: ?*const fn(GLuint, [*:0]const GLchar) callconv(.C) GLint = null;
var _UniformMatrix4fv: ?*const fn(GLint, GLsizei, GLboolean, [*]const GLfloat) callconv(.C) void = null;
var _Uniform1i:        ?*const fn(GLint, GLint) callconv(.C) void = null;
var _Uniform1f:        ?*const fn(GLint, GLfloat) callconv(.C) void = null;
var _Uniform3f:        ?*const fn(GLint, GLfloat, GLfloat, GLfloat) callconv(.C) void = null;
var _GenTextures:      ?*const fn(GLsizei, [*]GLuint) callconv(.C) void = null;
var _BindTexture:      ?*const fn(GLenum, GLuint) callconv(.C) void = null;
var _TexImage2D:       ?*const fn(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, ?*const GLvoid) callconv(.C) void = null;
var _TexImage3D:       ?*const fn(GLenum, GLint, GLint, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, ?*const GLvoid) callconv(.C) void = null;
var _TexSubImage3D:    ?*const fn(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, ?*const GLvoid) callconv(.C) void = null;
var _TexParameteri:    ?*const fn(GLenum, GLenum, GLint) callconv(.C) void = null;
var _ActiveTexture:    ?*const fn(GLenum) callconv(.C) void = null;
var _PixelStorei:      ?*const fn(GLenum, GLint) callconv(.C) void = null;
var _Enable:           ?*const fn(GLenum) callconv(.C) void = null;
var _Disable:          ?*const fn(GLenum) callconv(.C) void = null;
var _CullFace:         ?*const fn(GLenum) callconv(.C) void = null;
var _DepthFunc:        ?*const fn(GLenum) callconv(.C) void = null;
var _BlendFunc:        ?*const fn(GLenum, GLenum) callconv(.C) void = null;
var _Clear:            ?*const fn(GLbitfield) callconv(.C) void = null;
var _ClearColor:       ?*const fn(GLfloat, GLfloat, GLfloat, GLfloat) callconv(.C) void = null;
var _Viewport:         ?*const fn(GLint, GLint, GLsizei, GLsizei) callconv(.C) void = null;
var _DeleteBuffers:    ?*const fn(GLsizei, [*]const GLuint) callconv(.C) void = null;
var _DeleteVertexArrays: ?*const fn(GLsizei, [*]const GLuint) callconv(.C) void = null;
var _GenerateMipmap:   ?*const fn(GLenum) callconv(.C) void = null;

pub const GetProcFn = fn([*:0]const u8) callconv(.C) ?*anyopaque;

pub fn init(getProcAddress: *const GetProcFn) void {
    _GenVertexArrays  = @ptrCast(getProcAddress("glGenVertexArrays"));
    _BindVertexArray  = @ptrCast(getProcAddress("glBindVertexArray"));
    _GenBuffers       = @ptrCast(getProcAddress("glGenBuffers"));
    _BindBuffer       = @ptrCast(getProcAddress("glBindBuffer"));
    _BufferData       = @ptrCast(getProcAddress("glBufferData"));
    _BufferSubData    = @ptrCast(getProcAddress("glBufferSubData"));
    _EnableVertexAttribArray = @ptrCast(getProcAddress("glEnableVertexAttribArray"));
    _VertexAttribIPointer = @ptrCast(getProcAddress("glVertexAttribIPointer"));
    _DrawArrays       = @ptrCast(getProcAddress("glDrawArrays"));
    _DrawElements     = @ptrCast(getProcAddress("glDrawElements"));
    _CreateShader     = @ptrCast(getProcAddress("glCreateShader"));
    _ShaderSource     = @ptrCast(getProcAddress("glShaderSource"));
    _CompileShader    = @ptrCast(getProcAddress("glCompileShader"));
    _GetShaderiv      = @ptrCast(getProcAddress("glGetShaderiv"));
    _GetShaderInfoLog = @ptrCast(getProcAddress("glGetShaderInfoLog"));
    _CreateProgram    = @ptrCast(getProcAddress("glCreateProgram"));
    _AttachShader     = @ptrCast(getProcAddress("glAttachShader"));
    _LinkProgram      = @ptrCast(getProcAddress("glLinkProgram"));
    _GetProgramiv     = @ptrCast(getProcAddress("glGetProgramiv"));
    _UseProgram       = @ptrCast(getProcAddress("glUseProgram"));
    _DeleteShader     = @ptrCast(getProcAddress("glDeleteShader"));
    _GetUniformLocation = @ptrCast(getProcAddress("glGetUniformLocation"));
    _UniformMatrix4fv = @ptrCast(getProcAddress("glUniformMatrix4fv"));
    _Uniform1i        = @ptrCast(getProcAddress("glUniform1i"));
    _Uniform1f        = @ptrCast(getProcAddress("glUniform1f"));
    _Uniform3f        = @ptrCast(getProcAddress("glUniform3f"));
    _GenTextures      = @ptrCast(getProcAddress("glGenTextures"));
    _BindTexture      = @ptrCast(getProcAddress("glBindTexture"));
    _TexImage2D       = @ptrCast(getProcAddress("glTexImage2D"));
    _TexImage3D       = @ptrCast(getProcAddress("glTexImage3D"));
    _TexSubImage3D    = @ptrCast(getProcAddress("glTexSubImage3D"));
    _TexParameteri    = @ptrCast(getProcAddress("glTexParameteri"));
    _ActiveTexture    = @ptrCast(getProcAddress("glActiveTexture"));
    _PixelStorei      = @ptrCast(getProcAddress("glPixelStorei"));
    _Enable           = @ptrCast(getProcAddress("glEnable"));
    _Disable          = @ptrCast(getProcAddress("glDisable"));
    _CullFace         = @ptrCast(getProcAddress("glCullFace"));
    _DepthFunc        = @ptrCast(getProcAddress("glDepthFunc"));
    _BlendFunc        = @ptrCast(getProcAddress("glBlendFunc"));
    _Clear            = @ptrCast(getProcAddress("glClear"));
    _ClearColor       = @ptrCast(getProcAddress("glClearColor"));
    _Viewport         = @ptrCast(getProcAddress("glViewport"));
    _DeleteBuffers    = @ptrCast(getProcAddress("glDeleteBuffers"));
    _DeleteVertexArrays = @ptrCast(getProcAddress("glDeleteVertexArrays"));
    _GenerateMipmap   = @ptrCast(getProcAddress("glGenerateMipmap"));
}

pub fn genVertexArrays(n: GLsizei, arrays: [*]GLuint) void { _GenVertexArrays.?(n, arrays); }
pub fn bindVertexArray(array: GLuint) void { _BindVertexArray.?(array); }
pub fn genBuffers(n: GLsizei, buffers: [*]GLuint) void { _GenBuffers.?(n, buffers); }
pub fn bindBuffer(target: GLenum, buffer: GLuint) void { _BindBuffer.?(target, buffer); }
pub fn bufferData(target: GLenum, size: GLsizeiptr, data: ?*const GLvoid, usage: GLenum) void { _BufferData.?(target, size, data, usage); }
pub fn bufferSubData(target: GLenum, offset: GLsizeiptr, size: GLsizeiptr, data: ?*const GLvoid) void { _BufferSubData.?(target, offset, size, data); }
pub fn enableVertexAttribArray(index: GLuint) void { _EnableVertexAttribArray.?(index); }
pub fn vertexAttribIPointer(index: GLuint, size: GLint, typ: GLenum, stride: GLsizei, offset: usize) void { _VertexAttribIPointer.?(index, size, typ, stride, offset); }
pub fn drawArrays(mode: GLenum, first: GLint, count: GLsizei) void { _DrawArrays.?(mode, first, count); }
pub fn drawElements(mode: GLenum, count: GLsizei, typ: GLenum, offset: usize) void { _DrawElements.?(mode, count, typ, offset); }
pub fn createShader(typ: GLenum) GLuint { return _CreateShader.?(typ); }
pub fn shaderSource(shader: GLuint, count: GLsizei, src: [*]const [*]const GLchar, len: ?[*]const GLint) void { _ShaderSource.?(shader, count, src, len); }
pub fn compileShader(shader: GLuint) void { _CompileShader.?(shader); }
pub fn getShaderiv(shader: GLuint, pname: GLenum, params: [*]GLint) void { _GetShaderiv.?(shader, pname, params); }
pub fn getShaderInfoLog(shader: GLuint, max: GLsizei, len: ?*GLsizei, log: [*]GLchar) void { _GetShaderInfoLog.?(shader, max, len, log); }
pub fn createProgram() GLuint { return _CreateProgram.?(); }
pub fn attachShader(program: GLuint, shader: GLuint) void { _AttachShader.?(program, shader); }
pub fn linkProgram(program: GLuint) void { _LinkProgram.?(program); }
pub fn getProgramiv(program: GLuint, pname: GLenum, params: [*]GLint) void { _GetProgramiv.?(program, pname, params); }
pub fn useProgram(program: GLuint) void { _UseProgram.?(program); }
pub fn deleteShader(shader: GLuint) void { _DeleteShader.?(shader); }
pub fn getUniformLocation(program: GLuint, name: [*:0]const GLchar) GLint { return _GetUniformLocation.?(program, name); }
pub fn uniformMatrix4fv(loc: GLint, count: GLsizei, transpose: GLboolean, value: [*]const GLfloat) void { _UniformMatrix4fv.?(loc, count, transpose, value); }
pub fn uniform1i(loc: GLint, v: GLint) void { _Uniform1i.?(loc, v); }
pub fn uniform1f(loc: GLint, v: GLfloat) void { _Uniform1f.?(loc, v); }
pub fn uniform3f(loc: GLint, x: GLfloat, y: GLfloat, z: GLfloat) void { _Uniform3f.?(loc, x, y, z); }
pub fn genTextures(n: GLsizei, textures: [*]GLuint) void { _GenTextures.?(n, textures); }
pub fn bindTexture(target: GLenum, texture: GLuint) void { _BindTexture.?(target, texture); }
pub fn texImage2D(target: GLenum, level: GLint, internalFormat: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, typ: GLenum, data: ?*const GLvoid) void { _TexImage2D.?(target, level, internalFormat, width, height, border, format, typ, data); }
pub fn texImage3D(target: GLenum, level: GLint, internalFormat: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, format: GLenum, typ: GLenum, data: ?*const GLvoid) void { _TexImage3D.?(target, level, internalFormat, width, height, depth, border, format, typ, data); }
pub fn texSubImage3D(target: GLenum, level: GLint, xoff: GLint, yoff: GLint, zoff: GLint, w: GLsizei, h: GLsizei, d: GLsizei, format: GLenum, typ: GLenum, data: ?*const GLvoid) void { _TexSubImage3D.?(target, level, xoff, yoff, zoff, w, h, d, format, typ, data); }
pub fn texParameteri(target: GLenum, pname: GLenum, param: GLint) void { _TexParameteri.?(target, pname, param); }
pub fn activeTexture(texture: GLenum) void { _ActiveTexture.?(texture); }
pub fn pixelStorei(pname: GLenum, param: GLint) void { _PixelStorei.?(pname, param); }
pub fn enable(cap: GLenum) void { _Enable.?(cap); }
pub fn disable(cap: GLenum) void { _Disable.?(cap); }
pub fn cullFace(mode: GLenum) void { _CullFace.?(mode); }
pub fn depthFunc(func: GLenum) void { _DepthFunc.?(func); }
pub fn blendFunc(sfactor: GLenum, dfactor: GLenum) void { _BlendFunc.?(sfactor, dfactor); }
pub fn clear(mask: GLbitfield) void { _Clear.?(mask); }
pub fn clearColor(r: GLfloat, g: GLfloat, b: GLfloat, a: GLfloat) void { _ClearColor.?(r, g, b, a); }
pub fn viewport(x: GLint, y: GLint, w: GLsizei, h: GLsizei) void { _Viewport.?(x, y, w, h); }
pub fn deleteBuffers(n: GLsizei, buffers: [*]const GLuint) void { _DeleteBuffers.?(n, buffers); }
pub fn deleteVertexArrays(n: GLsizei, arrays: [*]const GLuint) void { _DeleteVertexArrays.?(n, arrays); }
pub fn generateMipmap(target: GLenum) void { _GenerateMipmap.?(target); }
