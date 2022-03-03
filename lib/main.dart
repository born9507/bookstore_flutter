import 'package:bookstore/book_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'book.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => BookService())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<BookService>(builder: (context, bookService, child) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'Book Store',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: Size(0, 60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Text(
                      'total 0',
                      textAlign: TextAlign.end,
                    ),
                  ),
                  TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: '원하시는 책을 검색해주세요.',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          if (_textEditingController.text.length > 0) {
                            Response result = await Dio().get(
                                'https://www.googleapis.com/books/v1/volumes',
                                queryParameters: {
                                  'q': _textEditingController.text,
                                  'startIndex': 0,
                                  'maxResults': 10,
                                });

                            bookService.clearBooks();

                            for (var item in result.data['items']) {
                              Book book = Book(
                                title: item['volumeInfo']['title'] ?? '',
                                subtitle: item['volumeInfo']['subtitle'] ?? '',
                                thumbnail: item['volumeInfo']['imageLinks']
                                        ['thumbnail'] ??
                                    '',
                                previewLink:
                                    item['volumeInfo']['previewLink'] ?? '',
                              );

                              bookService.createBook(book);
                            }
                          }
                        },
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: bookService.bookList.length,
          itemBuilder: ((context, index) {
            Book book = bookService.bookList[index];
            return ListTile(
              leading: Image.network(book.thumbnail),
              title: Text(book.title),
              subtitle: Text(book.subtitle),
              onTap: () {
                launch(book.previewLink);
              },
            );
          }),
        ),
      );
    });
  }
}
