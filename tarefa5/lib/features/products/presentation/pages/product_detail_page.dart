import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';
import 'product_form_page.dart';

/// Tela de detalhes do produto.
/// Recebe um [Product] pelo construtor e exibe todas as suas informações.
/// Permite editar e excluir o produto.
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// Constrói uma linha de estrelas com base na avaliação (0 a 5).
  Widget _buildStars(double rating) {
    final int fullStars = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < fullStars ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  /// Exibe diálogo de confirmação e, se confirmado, remove o produto.
  Future<void> _confirmarExclusao() async {
    // Captura recursos de context antes de qualquer gap assíncrono
    final viewModel = Provider.of<ProductViewModel>(context, listen: false);

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente remover este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final sucesso = await viewModel.deleteProduct(widget.product.id);

    if (!mounted) return;

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto removido com sucesso')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover produto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        backgroundColor: colorScheme.surface,
        actions: [
          // Botão de edição
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar produto',
            onPressed: () async {
              // Captura o navigator antes do gap assíncrono
              final navigator = Navigator.of(context);
              final result = await navigator.push(
                MaterialPageRoute(
                  builder: (context) => ProductFormPage(product: product),
                ),
              );
              if (!mounted) return;
              if (result == true) {
                // Retorna para a listagem sinalizando mudança
                navigator.pop(true);
              }
            },
          ),
          // Botão de exclusão
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Remover produto',
            onPressed: _confirmarExclusao,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem do produto em destaque
            Container(
              height: 300,
              color: Colors.white,
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do produto
                  Text(
                    product.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chip com a categoria
                  if (product.category.isNotEmpty)
                    Chip(
                      label: Text(product.category),
                      avatar: const Icon(Icons.category, size: 16),
                      visualDensity: VisualDensity.compact,
                    ),
                  const SizedBox(height: 12),

                  // Preço em destaque
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Avaliação: estrelas + contagem
                  Row(
                    children: [
                      _buildStars(product.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${product.rating.toStringAsFixed(1)} '
                        '(${product.ratingCount} avaliações)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  // Título da seção de descrição
                  Text(
                    'Descrição',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descrição completa do produto
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'Descrição não disponível.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botão de voltar à listagem
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar à listagem'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
