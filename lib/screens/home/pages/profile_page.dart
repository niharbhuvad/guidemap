import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guidemap/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:guidemap/utils/x_colors.dart';
import 'package:guidemap/utils/x_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitialState) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AuthLoggedInState) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Material(
                color: XColors.white,
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: XColors.greyDark.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 20),
                  child: Column(
                    children: [
                      getProfileView(context, state),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: XWidgets.iconTextBtn(
                              iconData: Icons.edit,
                              text: 'Edit Profile',
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: XWidgets.iconTextBtn(
                              iconData: Icons.logout,
                              text: 'Log Out',
                              onPressed: () =>
                                  context.read<AuthCubit>().signOut(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('User Not Found!'));
      },
    );
  }

  Widget getProfileView(BuildContext context, AuthLoggedInState authState) {
    return Row(
      children: [
        const CircleAvatar(
          minRadius: 55,
          backgroundColor: XColors.greyHighlight,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                authState.user.name,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                authState.user.email,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                  color: XColors.greyDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '@${authState.user.username}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  color: XColors.greyDark.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
