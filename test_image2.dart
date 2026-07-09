import 'dart:io';

void main() async {
  var urls = [
    'https://temple.jobes24x7.com/api/uploads/kula_deivams/kuladeivam_1782880420431_407167440.jpg',
    'https://temple.jobes24x7.com/api/storage/kula_deivams/kuladeivam_1782880420431_407167440.jpg',
    'https://temple.jobes24x7.com/api/uploads/kuladeivam_1782880420431_407167440.jpg',
    'https://temple.jobes24x7.com/api/storage/kuladeivam_1782880420431_407167440.jpg',
    'https://temple.jobes24x7.com/api/kuladeivam_1782880420431_407167440.jpg',
    'https://temple.jobes24x7.com/api/public/uploads/kuladeivam_1782880420431_407167440.jpg'
  ];
  var client = HttpClient();
  client.connectionTimeout = Duration(seconds: 3);
  for (var url in urls) {
    try {
      var req = await client.getUrl(Uri.parse(url));
      var res = await req.close();
      print(url + " => " + res.statusCode.toString() + " " + (res.headers.contentType?.toString() ?? "no content type"));
    } catch (e) {
      print(url + " => Error");
    }
  }
  exit(0);
}
