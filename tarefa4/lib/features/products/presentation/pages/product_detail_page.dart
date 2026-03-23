import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';

/// Tela de detalhes do produto.
/// Recebe um [Product] pelo construtor e exibe todas as suas informações.
class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  /// Constrói uma linha de estrelas com base na avaliação (0 a 5).
  Widget _buildStars(double rating) {
    // Arredonda para o inteiro mais próximo para exibir estrelas cheias/vazias
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produto'),
        // O Flutter já adiciona botão de voltar automaticamente,
        // mas mantemos a consistência com Material 3
        backgroundColor: colorScheme.surface,
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
                // Fallback caso a imagem não carregue
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
                      height: 1.5, // Espaçamento entre linhas para melhor leitura
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
