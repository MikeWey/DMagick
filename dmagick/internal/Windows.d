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

Window[HWND] windows;

class Window
{
	Image image;
	size_t height;
	size_t width;
	
	WNDCLASS  wndclass;
	HINSTANCE hInstance;
	HWND      hwnd;
	MSG       msg;

	this(Image image)
	{
		this.image = image;
		
		height = image.rows;
		width = image.columns;
		
		hInstance = cast(HINSTANCE) GetModuleHandleA(null);
		
		wndclass.style         = CS_HREDRAW | CS_VREDRAW;
		wndclass.lpfnWndProc   = &WndProc;
		wndclass.cbClsExtra    = 0;
		wndclass.cbWndExtra    = 0;
		wndclass.hInstance     = hInstance;
		wndclass.hIcon         = LoadIconA(null, IDI_APPLICATION);
		wndclass.hCursor       = LoadCursorA(null, IDC_ARROW);
		wndclass.hbrBackground = null;
		wndclass.lpszMenuName  = "DMagick";
		wndclass.lpszClassName = "DMagick";

		if (!RegisterClassA(&wndclass))
			throw new DMagickException("This program requires Windows NT!");

		RECT rect = RECT(0,0, width,height);
		AdjustWindowRect(&rect, WS_OVERLAPPEDWINDOW, false);
		
		hwnd = CreateWindowA("DMagick", "DMagick", WS_OVERLAPPEDWINDOW,
			CW_USEDEFAULT, CW_USEDEFAULT, rect.right-rect.left, rect.bottom-rect.top,
			null, null, hInstance, null);

		windows[hwnd] = this;
	}
	
	void display()
	{
		ShowWindow(hwnd, SW_SHOWNORMAL);
		UpdateWindow(hwnd);

		while (GetMessageA(&msg, null, 0, 0))
		{
			TranslateMessage(&msg);
			DispatchMessageA(&msg);
		}
	}
	
	extern(Windows) static LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
	{
		static int cxClient, cyClient, cxSource, cySource;
		int x, y;
		HDC hdc;
		PAINTSTRUCT ps;

		static HDC     hdcMem;
		static HBITMAP hbmMem;
		static HANDLE  hOld;
		RECT rect;
		
		switch (message)
		{
			case WM_SIZE:
				cxClient = LOWORD(lParam);
				cyClient = HIWORD(lParam);
				return 0;

			case WM_ERASEBKGND:  // don't redraw bg
				return 1;
			
			case WM_PAINT:
			{
				// Get DC for window
				hdc = BeginPaint(hwnd, &ps);

				// Create an off-screen DC for double-buffering
				hdcMem = CreateCompatibleDC(hdc);
				hbmMem = CreateCompatibleBitmap(hdc, cxClient, cyClient);
				hOld = SelectObject(hdcMem, hbmMem);
			
				// Draw into hdcMem
				GetClientRect(hwnd, &rect);
				FillRect(hdcMem, &rect, GetStockObject(BLACK_BRUSH));
				
				windows[hwnd].DrawAlphaBlend(hwnd, hdcMem);
				
				// Transfer the off-screen DC to the screen
				BitBlt(hdc, 0, 0, cxClient, cyClient, hdcMem, 0, 0, SRCCOPY);

				// Free-up the off-screen DC
				SelectObject(hdcMem, hOld);
				DeleteObject(hbmMem);
				DeleteDC (hdcMem);

				EndPaint(hwnd, &ps);
				return 0;
			}
			
			case WM_DESTROY:
				windows[hwnd] = null;
				PostQuitMessage(0);
				return 0;

			default:
		}

		return DefWindowProcA(hwnd, message, wParam, lParam);
	}
	
	void DrawAlphaBlend(HWND hWnd, HDC hdcwnd)
	{
		HDC hdc;                              // handle of the DC we will create
		HBITMAP hbitmap;                      // bitmap handle
		BITMAPINFO bmi;                       // bitmap header
		VOID*  pvBits;                        // pointer to DIB section
		ULONG  ulWindowWidth, ulWindowHeight; // window width/height
		RECT   rt;                            // used for getting window dimensions
		
		// get window dimensions
		GetClientRect(hWnd, &rt);

		// calculate window width/height
		ulWindowWidth  = rt.right - rt.left;
		ulWindowHeight = rt.bottom - rt.top;

		// make sure we have at least some window size
		if (ulWindowWidth < 1 || ulWindowHeight < 1)
			return;

		// create a DC for our bitmap -- the source DC for GdiAlphaBlend
		hdc = CreateCompatibleDC(hdcwnd);
		
		// setup bitmap info
		bmi.bmiHeader.biSize        = BITMAPINFOHEADER.sizeof;
		bmi.bmiHeader.biWidth       = width;
		bmi.bmiHeader.biHeight      = -height;  // must be inverted so Y axis is at top
		bmi.bmiHeader.biPlanes      = 1;
		bmi.bmiHeader.biBitCount    = 32;      // four 8-bit components
		bmi.bmiHeader.biCompression = BI_RGB;
		bmi.bmiHeader.biSizeImage   = width * height * 4;

		// create our DIB section and select the bitmap into the dc
		hbitmap = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, &pvBits, null, 0x0);
		SelectObject(hdc, hbitmap);

		auto area = Geometry(width, height, 0, 0);
		enum channels = "BGRA";  // win32 uses BGR(A)
		byte[] arr = (cast(byte*)pvBits)[0 .. (area.width * area.height) * channels.length];
		image.exportPixels(area, arr, channels);

		//TODO: Rezize image.
		BitBlt(hdcwnd, 0, 0, width, height, hdc, 0, 0, SRCCOPY);

		DeleteObject(hbitmap);
		DeleteDC(hdc);
	}
}

pragma(lib, "gdi32.lib");

const AC_SRC_OVER  = 0x00;
const AC_SRC_ALPHA = 0x01;
const GWLP_USERDATA = -21;

enum DWORD BI_RGB = 0;
enum UINT DIB_RGB_COLORS = 0;

struct BLENDFUNCTION
{
	BYTE BlendOp;
	BYTE BlendFlags;
	BYTE SourceConstantAlpha;
	BYTE AlphaFormat;
}

struct AlphaBlendType
{
	static normal = BLENDFUNCTION(AC_SRC_OVER, 0, 255, AC_SRC_ALPHA);
}

extern(Windows) BOOL BitBlt(HDC, int, int, int, int, HDC, int, int, DWORD);
extern(Windows) HBITMAP CreateCompatibleBitmap(HDC, int, int);
extern(Windows) HBITMAP CreateDIBSection(HDC, const(BITMAPINFO)*, UINT, void**, HANDLE, DWORD);