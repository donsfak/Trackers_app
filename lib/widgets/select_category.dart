import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackers_app/providers/category_provider.dart';
import 'package:trackers_app/utils/extensions.dart';
import 'package:trackers_app/utils/task_categories.dart';
import 'package:trackers_app/widgets/circle_container.dart';

class SelectCategory extends ConsumerWidget {
  const SelectCategory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = TaskCategories.values.toList();
    final selectedCategory = ref.watch(categoryProvider);
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          Text(
            'Category',
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () {
                        ref.read(categoryProvider.notifier).state = category;
                      },
                      child: CircleContainer(
                        // ignore: deprecated_member_use
                        color: category.color.withOpacity(0.5),
                        child: Icon(
                          category.icon,
                          color: category == selectedCategory
                              ? context.colorScheme.primary
                              : category.color,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemCount: categories.length)),
        ],
      ),
    );
  }
}
