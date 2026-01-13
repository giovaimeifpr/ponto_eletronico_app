import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart';

class PdfPrinterService {
  Future<void> generateMonthlyReport({
    required UserModel user,
    required List<Map<String, dynamic>> punches,
    required List<DateTime> displayDays,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(user, displayDays),
          pw.SizedBox(height: 20),
          _buildTable(punches, displayDays),
          pw.SizedBox(height: 40),
          _buildFooter(user),
        ],
      ),
    );

    // Abre o preview de impressão/salvamento
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Extrato_Mensal_${user.fullName}.pdf',
    );
  }

  // Cabeçalho do PDF
  pw.Widget _buildHeader(UserModel user, List<DateTime> days) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ESPELHO DE PONTO MENSAL',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('Colaborador: ${user.fullName}'),
            pw.Text('Cargo: ${user.jobTitle ?? "N/A"}'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Período: ${DateFormat('MM/yyyy').format(days.first)}'),
            pw.Text('Carga Horária: ${user.workload}h/sem'),
          ],
        ),
      ],
    );
  }

  // // Tabela de Dados (Similar ao seu HistoryTable)
  pw.Widget _buildTable(
    List<Map<String, dynamic>> punches,
    List<DateTime> days,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['Dia', 'Semana', 'E1', 'S1', 'E2', 'S2'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      cellAlignment: pw.Alignment.center,

      // ESTILO DAS CÉLULAS (Conteúdo)
      cellStyle: const pw.TextStyle(fontSize: 10),

      // LÓGICA DE CORES POR LINHA
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),

      cellFormat: (index, data) => data, // Mantém o dado original
      // AQUI DEFINIMOS O ESTILO DE CADA CÉLULA INDIVIDUALMENTE
      cellDecoration: (index, data, row) {
        return const pw.BoxDecoration(); // BoxDecoration vazio por padrão
      },

      data: days.map((dia) {
        final pontos = punches.where((p) {
          final dt = DateTime.parse(p['created_at']).toLocal();
          return dt.day == dia.day && dt.month == dia.month;
        }).toList();

        String e1 = "--:--", s1 = "--:--", e2 = "--:--", s2 = "--:--";
        for (var p in pontos) {
          final time = DateFormat(
            'HH:mm',
          ).format(DateTime.parse(p['created_at']).toLocal());
          if (p['entry_type'] == 'entry_1') e1 = time;
          if (p['entry_type'] == 'exit_1') s1 = time;
          if (p['entry_type'] == 'entry_2') e2 = time;
          if (p['entry_type'] == 'exit_2') s2 = time;
        }

        bool isSabado = dia.weekday == DateTime.saturday;
        bool isDomingo = dia.weekday == DateTime.sunday;

        // Função interna para definir a cor da fonte
        PdfColor getTextColor(bool isAfternoon) {
          if (isDomingo) return PdfColors.red;
          if (isSabado) return PdfColors.red;
          return PdfColors.black;
        }

        return [
          // Cada célula pode ter seu estilo formatado
          pw.Text(
            DateFormat('dd/MM').format(dia),
            style: pw.TextStyle(color: getTextColor(false)),
          ),
          pw.Text(
            DateFormat('E', 'pt_BR').format(dia).toUpperCase(),
            style: pw.TextStyle(color: getTextColor(false)),
          ),
          pw.Text(e1, style: pw.TextStyle(color: getTextColor(false))),
          pw.Text(s1, style: pw.TextStyle(color: getTextColor(false))),
          pw.Text(
            e2,
            style: pw.TextStyle(color: getTextColor(true)),
          ), // Tarde (isAfternoon: true)
          pw.Text(
            s2,
            style: pw.TextStyle(color: getTextColor(true)),
          ), // Tarde (isAfternoon: true)
        ];
      }).toList(),
    );
  }

  // Rodapé com Assinatura
  pw.Widget _buildFooter(UserModel user) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            pw.Column(
              children: [
                pw.Container(
                  width: 200,
                  // O erro estava aqui: usamos decoration + BoxDecoration
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(top: pw.BorderSide(width: 1)),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(user.fullName, style: const pw.TextStyle(fontSize: 10)),
                pw.Text(
                  'Assinatura do Colaborador',
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
