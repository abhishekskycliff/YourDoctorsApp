import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionGroupSeparator extends StatelessWidget {
final String practice;
int appointmentsCount;
final String locationName;
TransactionGroupSeparator(
    {this.practice, this.appointmentsCount, this.locationName});

@override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      children: [
        SizedBox(
          height: 5,
        ),
        Center(
          child: Text(
            "${this.practice}-${this.locationName} ${[
              this.appointmentsCount
            ]} ",
            style: GoogleFonts.montserrat(
                fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
          ),
        ),
      ],
    ),
  );
}
}