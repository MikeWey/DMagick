/**
 * Copyright: Mike Wey 2011
 * License:   zlib (See accompanying LICENSE file)
 * Authors:   Mike Wey
 */
 
module dmagick.internal.Windows;

import core.sys.windows.windows;

import dmagick.Image;
import dmagick.Exception;
import dmagick.Geometry;

class Window
{
	Image image;
	Image[] imageList;
	size_t index;
	size_t height;
	size_t width;

	WNDCLASS   wndclass;
	HINSTANCE  hInstance;
	BITMAPINFO bmi;          // bitmap header
	HWND       hwnd;
	MSG        msg;

	static Window[HWND] windows;

	/**
	 * Create an window foe displaying an image.
	 */
	this(Image image)
	{
		this.image = image;

		height = image.rows;
		width  = image.columns;

		hInstance = cast(HINSTANCE) GetModuleHandleA(null);

		wndclass.style         = CS_HREDRAW | CS_VREDRAW;
		wndclass.lpfnWndProc   = &WndProc;
		wndclass.cbClsExtra    = 0;
		wndclass.cbWndExtra    = 0;
		wndclass.hInstance     = hInstance;
		wndclass.hIcon         = LoadIconA(null, IDI_APPLICATION);
		wndclass.hCursor       = LoadCursorA(null, IDC_ARROW);
		wndclass.hbrBackground = null;
		wndclass.lpszMenuName  = null;
		wndclass.lpszClassName = "DMagick";

		if (!RegisterClassA(&wndclass))
			throw new DMagickException("Displaying images requires Windows NT!");

		RECT rect = RECT(0,0, width,height);
		AdjustWindowRect(&rect, WS_CAPTION | WS_SYSMENU, false);

		hwnd = CreateWindowA("DMagick", "DMagick", WS_CAPTION | WS_SYSMENU,
			CW_USEDEFAULT, CW_USEDEFAULT, rect.right-rect.left, rect.bottom-rect.top,
			null, null, hInstance, null);

		// setup bitmap info
		bmi.bmiHeader.biSize        = BITMAPINFOHEADER.sizeof;
		bmi.bmiHeader.biWidth       = width;
		bmi.bmiHeader.biHeight      = -height;  // must be inverted so Y axis is at top
		bmi.bmiHeader.biPlanes      = 1;
		bmi.bmiHeader.biBitCount    = 32;      // four 8-bit components
		bmi.bmiHeader.biCompression = BI_RGB;
		bmi.bmiHeader.biSizeImage   = width * height * 4;

		windows[hwnd] = this;
	}

	/**
	 * Create an window foe displaying an animation
	  * or a collection of images.
	 */
	this(Image[] images)
	{
		this(images[0]);

		imageList = images;
		index = 0;
	}

	/**
	 * Open the window and display the image.
	 */
	void display()
	{
		ShowWindow(hwnd, SW_SHOWNORMAL);
		UpdateWindow(hwnd);

		if ( imageList !is null )
		{
			UINT delay = cast(UINT)image.animationDelay.total!"msecs"();
			
			if ( delay == 0 )
				delay = 1000;
			
			SetTimer(hwnd, 0, delay, null);
		}

		while (GetMessageA(&msg, null, 0, 0))
		{
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}
	}

	extern(Windows) nothrow static LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
	{
		try
		{
			switch (message)
			{
				case WM_ERASEBKGND:  // don't redraw bg
					return 1;

				case WM_PAINT:
					windows[hwnd].draw();
					return 0;

				case WM_TIMER:
					windows[hwnd].nextFrame();
					return 0;

				case WM_DESTROY:
					windows[hwnd] = null;
					PostQuitMessage(0);
					return 0;

				default:
			}
		}
		catch(Exception e){}
		
		return DefWindowProcA(hwnd, message, wParam, lParam);
	}

	/**
	 * Draw the image on the window.
	 */
	void draw()
	{
		HDC hdc;                              // handle of the DC we will create
		HDC hdcwnd;                           // DC for the window
		HBITMAP hbitmap;                      // bitmap handle
		PAINTSTRUCT ps;
		VOID*  pvBits;                        // pointer to DIB section
		ULONG  ulWindowWidth, ulWindowHeight; // window width/height
		RECT   rt;                            // used for getting window dimensions

		// get window dimensions
		GetClientRect(hwnd, &rt);

		// calculate window width/height
		ulWindowWidth  = rt.right - rt.left;
		ulWindowHeight = rt.bottom - rt.top;

		// make sure we have at least some window size
		if (ulWindowWidth < 1 || ulWindowHeight < 1)
			return;

		// Get DC for window
		hdcwnd = BeginPaint(hwnd, &ps);

		// create a DC for our bitmap -- the source DC for BitBlt
		hdc = CreateCompatibleDC(hdcwnd);

		// create our DIB section and select the bitmap into the dc
		hbitmap = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, &pvBits, null, 0x0);
		SelectObject(hdc, hbitmap);

		enum channels = "BGRA";  // win32 uses BGR(A)
		Geometry area = Geometry(width, height);
		byte[] arr = (cast(byte*)pvBits)[0 .. (area.width * area.height) * channels.length];
		image.exportPixels(area, arr, channels);

		BitBlt(hdcwnd, 0, 0, width, height, hdc, 0, 0, SRCCOPY);

		DeleteObject(hbitmap);
		DeleteDC(hdc);
		EndPaint(hwnd, &ps);
	}

	/**
	 * Setup the next frame, and invalidate the window so its repainted.
	 */
	void nextFrame()
	{
		if (++index == imageList.length)
			index = 0;

		image = imageList[index];

		UINT delay = cast(UINT)image.animationDelay.total!"msecs"();
		
		if ( delay == 0 )
			delay = 1000;
				
		SetTimer(hwnd, 0, delay, null);
		InvalidateRect(hwnd,null,false);
	}
}

pragma(lib, "gdi32.lib");

const AC_SRC_OVER  = 0x00;
const AC_SRC_ALPHA = 0x01;

enum DWORD BI_RGB = 0;
enum UINT DIB_RGB_COLORS = 0;

extern(Windows) BOOL BitBlt(HDC, int, int, int, int, HDC, int, int, DWORD);
extern(Windows) HBITMAP CreateCompatibleBitmap(HDC, int, int);
extern(Windows) HBITMAP CreateDIBSection(HDC, const(BITMAPINFO)*, UINT, void**, HANDLE, DWORD);
extern(Windows) UINT_PTR SetTimer(HWND, UINT_PTR, UINT, TIMERPROC);